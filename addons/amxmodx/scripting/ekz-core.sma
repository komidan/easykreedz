/**
 * ekz-core.sma
 * Contains the Core of EasyKreedz (timer, demo)
 *
 * This file should be used as a style-guide for all other plugins, and contains
 * comments describing how to structure contributions.
 */

// Includes should be spaced depending on if they come from the ekz-api or from
// AMX Mod X's API. Sort them alphabetically.
#include <amxmisc>
#include <amxmodx>

#include <ekz-api/config>
#include <ekz-api/globals>
#include <ekz-api/messages>
#include <ekz-api/version>

// Plugin specific options/defines here.
#pragma semicolon 1

#define PLUGIN_NAME     "EKZ-Core"
#define PLUGIN_AUTHOR   "komidan"

/**
 * If your plugin is large enough to the point of spreading it out across
 * multiple files, include them using this syntax after defining and included
 * everything else. These includes do not and most likely can't be in
 * alphabetical order.
 */
#include "ekz-core/shared.sma" // Place forwards and global declarations here.
#include "ekz-core/respawn.sma"
#include "ekz-core/runner.sma"
#include "ekz-core/menus.sma"
#include "ekz-core/timer.sma"
#include "ekz-core/utilities.sma"

public plugin_init()
{
    // Initializing things from the API comes first.
    ekz_chat_init();

    // Always register plugin before other code.
    register_plugin(PLUGIN_NAME, EKZ_VERSION, PLUGIN_AUTHOR);

    // If your plugin is large enough it is split across files, create a
    // `plugin_init_(filename)` function and put it here.
    plugin_init_menus();
    plugin_init_respawn();
    plugin_init_timer();
    plugin_init_utilities();

#if defined DEBUG
    if (is_dedicated_server()) {
        log_amx("Running on a Dedicated Server");
        // server initialization here.
    } else {
        // sv_lan 1 (?)
        log_amx("Running on a LAN Server");
    }
#endif

    // Make sure the configuration directory exists, creates it if not.
    if (!ekz_config_dir_exists()) {
        new cfg_dir[128];
        ekz_get_config_dir(cfg_dir, charsmax(cfg_dir));
        mkdir(cfg_dir);
        log_amx("Configuration directory created");
    }
}

/**
 * Similar to the `plugin_init_(filename)` function call, extend the name for
 * all other included files.
 */
public client_putinserver(id)
{
    client_putinserver_timer(id);
}
