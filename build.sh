#!/usr/bin/env bash
# build.sh - Build Script for EasyKreedz (Linux)
# by komidan

set -Euo pipefail

# ---------------------------------------------------------------------------- #
# Configuration
# ---------------------------------------------------------------------------- #

# This script uses relative paths to the base `cstrike` folder.
# Default: `$HOME/.local/share/Steam/steamapps/common/Half-life/cstrike`
CSTRIKE_PATH="$HOME/.local/share/Steam/steamapps/common/Half-Life/cstrike"

# Directory to install compiled plugins to. Verify this before running command.
INSTALL_DIR="$CSTRIKE_PATH/addons/amxmodx/plugins"

# Root project directory, folder containing `build.sh`.
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Project Folders
SCRIPTING_DIR="$ROOT_DIR/addons/amxmodx/scripting"
PLUGINS_DIR="$ROOT_DIR/addons/amxmodx/plugins"

# All folders to search for `.inc` files.
INCLUDE_DIRS=(
    "$ROOT_DIR/addons/amxmodx/scripting/include"
    "$CSTRIKE_PATH/addons/amxmodx/scripting/include" # AMXModX API Includes
)

# You can change this, but for now the compiler is shipped with the repo
COMPILER="$ROOT_DIR/compiler/amxxpc"

# Optional defines passed into the compiler, same as `#define` in plugins.
SYMBOLS=(
    # "EXAMPLE=1"
)

# Extra flags to pass to compiler.
EXTRA_FLAGS=(
    "-;+" # Require Semi-Colons
)

# Debug level passed into amxx compiler. (amxxpc -h)
#   0  no symbolic information, no run-time checks
#   1  run-time checks, no symbolic information [default]
#   2  full debug information and dynamic checking
#   3  full debug information, dynamic checking, no optimization
DEBUG=""

# Verbosity level of compiler (amxxpc -h)
#   0   quiet
#   1   normal [default]
#   2   verbose
VERBOSE=""

# ---------------------------------------------------------------------------- #
# Usage Function
# ---------------------------------------------------------------------------- #

usage() {
    cat <<'EOF'
Usage: ./build.sh [options] [plugin ...]

Running the script with no plugin names will compile every .sma found in
the scripting folder, including subfolders.

Options:
    -h, --h                 Show this help message
    -c, --clean             Delete compiled plugins, then exit
    -C, --clean-and-build   Delete compiled plugins, then rebuild
    -I, --install           Moves plugins to `INSTALL_DIR` (not config files)
    -d, --debug <0-3>       Compile the plugins using debug levels
    -i, --include           Add extra include directories (repeatable)
    -D, --define <X[=Y]>    Define a symbol during compilation (repeatable)
    -v, --verbose <0-2>     Shows full compiler and script outputs

Environment:
    CSTRIKE_PATH            Local cstrike folder, used for relative paths
    INSTALL_DIR             Override where `--install` copies plugins to
EOF
}

# ---------------------------------------------------------------------------- #
# Logging
# ---------------------------------------------------------------------------- #
info() {
    printf '[INFO] %s\n' "$*"
}
good() {
    printf '[GOOD] %s\n' "$*"
}
warn() {
    printf '[WARN] %s\n' "$*" >&2
}
fail() {
    printf '[FAIL] %s\n' "$*" >&2
}
die() {
    fail "$*"; exit 1
}
need() {
    [[ -n "${2:-}" ]] || die "$1 needs a value"
}

# ---------------------------------------------------------------------------- #
# Argument Parsing
# ---------------------------------------------------------------------------- #

CLEAN=0 REBUILD=0 INSTALL=0
SOURCES=()

while [[ $# -gt 0 ]]; do
    case "$1" in
        -h|--help)            usage; exit 0 ;;
        -c|--clean)           CLEAN=1 ;;
        -C|--clean-and-build) CLEAN=1; REBUILD=1 ;;
        -I|--install)         INSTALL=1 ;;
        -d|--debug)           need "$1" "${2:-}"; DEBUG="$2"; shift ;;
        -i|--include)         need "$1" "${2:-}"; INCLUDE_DIRS+=("$2"); shift ;;
        -D|--define)          need "$1" "${2:-}"; SYMBOLS+=("$2"); shift ;;
        -v|--verbose)         need "$1" "${2:-}"; VERBOSE="$2"; shift ;;
        -*)                   die "Unknown option: $1 (see --help)" ;;
        *)                    SOURCES+=("$1") ;;
    esac
    shift
done

# ---------------------------------------------------------------------------- #
# Setup / Sanity Checks
# ---------------------------------------------------------------------------- #

[[ -x "$COMPILER" ]] || chmod +x "$COMPILER" || die "compiler not found"

# amxxpc wants amxxpc32.so next to itself
export LD_LIBRARY_PATH="$ROOT_DIR/compiler${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"

FOUND_INCLUDE=0

for dir in "${INCLUDE_DIRS[@]}"; do
    if [[ -f "$dir/amxmodx.inc" ]]; then
        FOUND_INCLUDE=1
        break
    fi
done

if [[ $FOUND_INCLUDE -eq 0 ]]; then
    die "amxmodx.inc not found. Check CSTRIKE_PATH or specify an include directory with -i"
fi

if [[ $INSTALL -eq 1 && ! -d "$INSTALL_DIR" ]]; then
    die "Install directory does not exist: $INSTALL_DIR"
fi

mkdir -p "$PLUGINS_DIR" || die "Couldn't create $PLUGINS_DIR"

FLAGS=("${EXTRA_FLAGS[@]}")
FLAGS+=("${SYMBOLS[@]}")

for dir in "${INCLUDE_DIRS[@]}"; do
    FLAGS+=("-i$dir")
done

[[ -n "$DEBUG" ]]   && FLAGS+=("-d$DEBUG")
[[ -n "$VERBOSE" ]] && FLAGS+=("-v$VERBOSE")

if [[ ${#SOURCES[@]} -eq 0 ]]; then
    while IFS= read -r file; do
        SOURCES+=("$file")
    done < <(find "$SCRIPTING_DIR" -path "$SCRIPTING_DIR/include" \
        -prune -o -name '*.sma' -print | sort)
fi

if [[ $CLEAN -eq 1 ]]; then
    rm -f "$PLUGINS_DIR"/*.amxx
    info "Cleaned compiled plugins"
    [[ $REBUILD -ne 0 ]] && exit 0
fi

# ---------------------------------------------------------------------------- #
# Compile
# ---------------------------------------------------------------------------- #

BUILT=()
FAILED=0

for src in "${SOURCES[@]}"; do
    # Resolve relative source paths against the scripting directory.
    if [[ ! -f "$src" ]]; then
        src="$SCRIPTING_DIR/${src%.sma}"
        [[ "$src" == *.sma ]] || src+=".sma"
    fi

    if [[ ! -f "$src" ]]; then
        fail "Source not found: $src"
        FAILED=$((FAILED + 1))
        continue
    fi

    # Use a path relative to SCRIPTING_DIR for the compiler.
    src="$(realpath --relative-to="$SCRIPTING_DIR" "$src")"
    out="$PLUGINS_DIR/$(basename "$src" .sma).amxx"
    rm -f "$out"

    if output="$(cd "$SCRIPTING_DIR" &&
        "$COMPILER" "$src" "-o$out" "${FLAGS[@]}" 2>&1)"; then
        good "$(basename "$out")"
        BUILT+=("$out")
    else
        fail "$(basename "$src")"
        echo "$output" >&2
        FAILED=$((FAILED + 1))
    fi
done

# ---------------------------------------------------------------------------- #
# Install / Summary
# ---------------------------------------------------------------------------- #

if [[ $INSTALL -eq 1 && ${#BUILT[@]} -gt 0 ]]; then
    cp -f "${BUILT[@]}" "$INSTALL_DIR/" && info "Installed ${#BUILT[@]} plugins"
fi

info "Done: ${#BUILT[@]} compiled, $FAILED failed"
exit $(( FAILED > 0 ))
