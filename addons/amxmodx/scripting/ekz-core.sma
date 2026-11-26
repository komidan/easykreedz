/**
 * ekz-core.sma
 *
 * Contains the classical minimum for legal Kreedz'ing.
 */

#include <amxmisc>
#include <amxmodx>
#include <hamsandwich>

#include <ekz-api/config>
#include <ekz-api/messages.inc>

#include <ekz-core/globals>
#include <ekz-core/respawn>
#include <ekz-core/timer>
#include <ekz-core/utilities>
#include <ekz-core/version>

#include <ekz-core/menus/main>
#include <ekz-core/menus/runner>
#include <ekz-core/menus/settings>

#pragma semicolon 1

#define PLUGIN_NAME     "EKZ-Core"
#define PLUGIN_AUTHOR   "komidan"

register_hams()
{
    RegisterHam(Ham_Use, "func_button", "OnButtonUse", 0); // timer.inc
    RegisterHam(Ham_TakeDamage, "player", "OnTakeDamage"); // respawn.inc
}

public plugin_init()
{
    register_plugin(PLUGIN_NAME, EKZ_VERSION, PLUGIN_AUTHOR);

    register_clcmd("say /ekz", "cmd_MenuShowMain");

    // NOTE: Bindings for Menu options. Might be invasive to some
    // players/servers? Could just remove the 'buyammo' ones and leave the
    // 'chooseteam'.
    register_clcmd("chooseteam", "cmd_MenuShowMain");
    register_clcmd("buyammo1", "cmd_MenuShowRunner");
    register_clcmd("buyammo2", "cmd_MenuShowSettings");

    register_clcmd("say /god", "cmd_God");

    ekz_chat_init(); // Sets the prefix for CromChat.

    init_entities(); // For the Timer
    register_hams(); // Register's all Hams for the ekz-core plugin.

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

public client_putinserver(id)
{
    init_timer(id);
}

// do #if defined SERVER for client_connextex/disconnected/remove?
