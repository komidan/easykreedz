/**
 * ekz-core.sma
 *
 * Contains the classical minimum for legal Kreedz'ing.
 */

#include <amxmisc>
#include <amxmodx>

#include <ekz-api/config>
#include <ekz-api/messages.inc>

#include <ekz-core/globals>
#include <ekz-core/version>
#include <ekz-core/menus/runner>
#include <ekz-core/menus/main>
#include <ekz-core/menus/settings>

#pragma semicolon 1

#define PLUGIN_NAME     "EKZ-Core"
#define PLUGIN_AUTHOR   "komidan"

public plugin_init()
{
    register_plugin(PLUGIN_NAME, EKZ_VERSION, PLUGIN_AUTHOR);

    register_clcmd("say /ekz", "cmd_MenuShowMain");

    register_clcmd("chooseteam", "cmd_MenuShowMain");
    register_clcmd("buyammo1", "cmd_MenuShowRunner");
    register_clcmd("buyammo2", "cmd_MenuShowSettings");

    ekz_chat_init(); // Sets the prefix for CromChat.

#if defined DEBUG
    if (is_dedicated_server()) {
        log_amx("Running on a Dedicated Server");
        // server initialization here.
    } else {
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

// do #if defined SERVER for client_connextex/disconnected/remove?
