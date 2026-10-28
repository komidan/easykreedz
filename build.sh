#!/usr/bin/env bash
# build.sh - Build Script for EasyKreedz (Linux)
# by komidan

set -Euo pipefail

# ---------------------------------------------------------------------------- #
# Configuration
# ---------------------------------------------------------------------------- #

# Local cstrike folder. Used for AMXModX includes, `--install`, `--full-install`.
# Default: `$HOME/.local/share/Steam/steamapps/common/Half-Life/cstrike`
CSTRIKE_PATH="${CSTRIKE_PATH:-$HOME/.local/share/Steam/steamapps/common/Half-Life/cstrike}"

# Directory to install compiled plugins to. Verify this before running command.
INSTALL_DIR="${INSTALL_DIR:-$CSTRIKE_PATH/addons/amxmodx/plugins}"

# Root project directory, folder containing `build.sh`.
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Project Folders
SCRIPTING_DIR="$ROOT_DIR/addons/amxmodx/scripting"
PLUGINS_DIR="$ROOT_DIR/addons/amxmodx/plugins"
BUILD_DIR="$ROOT_DIR/build"           # Release staging + finished zips

# Name used for the release archive: <RELEASE_NAME>-<version>.zip
RELEASE_NAME="easykreedz"

# Folders (relative to the project root, mirroring `cstrike/`) that get packed
# into the release .zip and copied by `--full-install`. Entries that don't
# exist are skipped, so list anything you might use. Nested paths work too
# (e.g. "addons/amxmodx/configs").
#
# Always handled for you:
#   - addons/amxmodx/plugins/*.amxx is rebuilt fresh (no stale plugins)
#   - addons/amxmodx/scripting is left out unless --with-source is passed
FOLDERS_TO_ZIP=(
    "addons"
    "cfg"
    "maps"
    "models"
    "sound"
    "sprites"
    "materials"
    "gfx"
    "resource"
    "overviews"
    "media"
    "events"
    "scripts"
)

# All folders to search for `.inc` files.
INCLUDE_DIRS=(
    "$ROOT_DIR/addons/amxmodx/scripting/include"
    "$CSTRIKE_PATH/addons/amxmodx/scripting/include" # AMXModX API Includes
)

# You can change this, but for now the compiler is shipped with the repo
COMPILER="$ROOT_DIR/compiler/amxxpc"

# Optional defines passed into the compiler, same as `#define` in plugins.
# Must be NAME=value (a bare NAME is read as a file by amxxpc).
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
    -h, --help              Show this help message
    -c, --clean             Delete compiled plugins and build/, then exit
    -C, --clean-and-build   Delete compiled plugins and build/, then rebuild
    -I, --install           Copy plugins to `INSTALL_DIR` (not config files)
    -F, --full-install      Copy plugins AND every folder in FOLDERS_TO_ZIP
                            into `CSTRIKE_PATH`. Overwrites files!
    -r, --release [ver]     Build everything and package a release .zip in
                            build/ (version defaults to `git describe`,
                            else "dev")
    -s, --with-source       Include addons/amxmodx/scripting in the release
                            (or full install)
    -d, --debug <0-3>       Compile the plugins using debug levels
    -i, --include           Add extra include directories (repeatable)
    -D, --define <X[=Y]>    Define a symbol during compilation (repeatable)
    -v, --verbose <0-2>     Shows full compiler and script outputs

Environment:
    CSTRIKE_PATH            Local cstrike folder, used for relative paths
    INSTALL_DIR             Override where `--install` copies plugins to

The release .zip is meant to be extracted straight into your `cstrike` folder.
Edit FOLDERS_TO_ZIP at the top of this script to choose what gets packed.
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

CLEAN=0 REBUILD=0 INSTALL=0 FULL_INSTALL=0 RELEASE=0 WITH_SOURCE=0
VERSION=""
SOURCES=()

while [[ $# -gt 0 ]]; do
    case "$1" in
        -h|--help)            usage; exit 0 ;;
        -c|--clean)           CLEAN=1 ;;
        -C|--clean-and-build) CLEAN=1; REBUILD=1 ;;
        -I|--install)         INSTALL=1 ;;
        -F|--full-install)    FULL_INSTALL=1 ;;
        -r|--release)         RELEASE=1
                              # Optional version argument
                              if [[ -n "${2:-}" && "${2:0:1}" != "-" ]]; then
                                  VERSION="$2"; shift
                              fi ;;
        -s|--with-source)     WITH_SOURCE=1 ;;
        -d|--debug)           need "$1" "${2:-}"; DEBUG="$2"; shift ;;
        -i|--include)         need "$1" "${2:-}"; INCLUDE_DIRS+=("$2"); shift ;;
        -D|--define)          need "$1" "${2:-}"
                              # amxxpc needs NAME=value; a bare NAME would be
                              # read as another source file (NAME.p).
                              [[ "$2" == *=* ]] && SYMBOLS+=("$2") || SYMBOLS+=("$2=1")
                              shift ;;
        -v|--verbose)         need "$1" "${2:-}"; VERBOSE="$2"; shift ;;
        -*)                   die "Unknown option: $1 (see --help)" ;;
        *)                    SOURCES+=("$1") ;;
    esac
    shift
done

# ---------------------------------------------------------------------------- #
# Clean
# ---------------------------------------------------------------------------- #

if [[ $CLEAN -eq 1 ]]; then
    rm -f "$PLUGINS_DIR"/*.amxx
    rm -rf "$BUILD_DIR"
    info "Cleaned compiled plugins and build folder"
    [[ $REBUILD -eq 0 ]] && exit 0
fi

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

if [[ $FULL_INSTALL -eq 1 && ! -d "$CSTRIKE_PATH" ]]; then
    die "cstrike directory does not exist: $CSTRIKE_PATH"
fi

if [[ $RELEASE -eq 1 || $FULL_INSTALL -eq 1 ]]; then
    # These must always contain every plugin.
    if [[ ${#SOURCES[@]} -gt 0 ]]; then
        die "--release and --full-install build all plugins; don't pass plugin names"
    fi
fi

if [[ $RELEASE -eq 1 && -z "$VERSION" ]]; then
    VERSION="$(git -C "$ROOT_DIR" describe --tags --always --dirty 2>/dev/null || true)"
    VERSION="${VERSION:-dev}"
fi

mkdir -p "$PLUGINS_DIR" || die "Couldn't create $PLUGINS_DIR"

FLAGS=("${EXTRA_FLAGS[@]}")
FLAGS+=(${SYMBOLS[@]+"${SYMBOLS[@]}"})

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

# ---------------------------------------------------------------------------- #
# Compile
# ---------------------------------------------------------------------------- #

BUILT=()
FAILED=0

for src in ${SOURCES[@]+"${SOURCES[@]}"}; do
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
# Packaging helpers
# ---------------------------------------------------------------------------- #

stage_files() {
    # stage_files <staging dir>
    # Builds the tree that mirrors `cstrike/` from FOLDERS_TO_ZIP + plugins.
    local stage="$1" folder
    rm -rf "$stage"
    mkdir -p "$stage"

    cd "$ROOT_DIR" || die "Couldn't enter $ROOT_DIR"

    for folder in "${FOLDERS_TO_ZIP[@]}"; do
        folder="${folder#/}"; folder="${folder%/}"
        [[ -e "$folder" ]] && cp -r --parents "$folder" "$stage/"
    done

    # Source is opt-in.
    rm -rf "$stage/addons/amxmodx/scripting"
    if [[ $WITH_SOURCE -eq 1 && -d "addons/amxmodx/scripting" ]]; then
        cp -r --parents "addons/amxmodx/scripting" "$stage/"
    fi

    # Only ship plugins that were just built, never stale ones.
    rm -f "$stage/addons/amxmodx/plugins/"*.amxx
    mkdir -p "$stage/addons/amxmodx/plugins"
    cp -f "${BUILT[@]}" "$stage/addons/amxmodx/plugins/"

    # Placeholders are for git only, never ship them.
    find "$stage" -name '.gitkeep' -delete
}

make_zip() {
    # make_zip <staging dir> <output zip>
    local stage="$1" zip_out="$2"
    rm -f "$zip_out"
    if command -v zip >/dev/null 2>&1; then
        (cd "$stage" && zip -qr "$zip_out" .)
    elif command -v python3 >/dev/null 2>&1; then
        python3 - "$stage" "$zip_out" <<'PY'
import os, sys, zipfile
stage, out = sys.argv[1], sys.argv[2]
with zipfile.ZipFile(out, "w", zipfile.ZIP_DEFLATED) as z:
    for root, _, files in os.walk(stage):
        for f in sorted(files):
            p = os.path.join(root, f)
            z.write(p, os.path.relpath(p, stage))
PY
    else
        die "Need either 'zip' or 'python3' to create the release archive"
    fi
}

# ---------------------------------------------------------------------------- #
# Release
# ---------------------------------------------------------------------------- #

build_release() {
    local stage="$BUILD_DIR/stage"
    local zip_out="$BUILD_DIR/$RELEASE_NAME-$VERSION.zip"

    info "Packaging release $VERSION"
    stage_files "$stage"
    make_zip "$stage" "$zip_out"
    rm -rf "$stage"
    good "$(realpath --relative-to="$ROOT_DIR" "$zip_out")"
}

if [[ $RELEASE -eq 1 ]]; then
    if [[ $FAILED -gt 0 || ${#BUILT[@]} -eq 0 ]]; then
        warn "Skipping release: build failed or produced no plugins"
    else
        build_release
    fi
fi

# ---------------------------------------------------------------------------- #
# Install / Summary
# ---------------------------------------------------------------------------- #

if [[ $INSTALL -eq 1 && ${#BUILT[@]} -gt 0 ]]; then
    cp -f "${BUILT[@]}" "$INSTALL_DIR/" && info "Installed ${#BUILT[@]} plugins"
fi

if [[ $FULL_INSTALL -eq 1 ]]; then
    if [[ $FAILED -gt 0 || ${#BUILT[@]} -eq 0 ]]; then
        warn "Skipping full install: build failed or produced no plugins"
    else
        stage="$BUILD_DIR/stage"
        stage_files "$stage"
        cp -r "$stage/." "$CSTRIKE_PATH/"
        rm -rf "$stage"
        info "Full install to $CSTRIKE_PATH (${#BUILT[@]} plugins + folders)"
    fi
fi

info "Done: ${#BUILT[@]} compiled, $FAILED failed"
exit $(( FAILED > 0 ))