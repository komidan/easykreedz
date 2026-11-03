/**
 * ekz-core.sma
 *
 * Contains the classical minimum for legal Kreedz'ing.
 */
#include <amxmodx>
#include <amxmisc>

#include <ekz-api/config>

#include <ekz-core/globals>
#include <ekz-core/version>

#pragma semicolon 1

#define PLUGIN_NAME     "EKZ-Core"
#define PLUGIN_AUTHOR   "komidan"

public plugin_cfg()
{
    return PLUGIN_HANDLED;
}

public plugin_init()
{
    register_plugin(PLUGIN_NAME, EKZ_VERSION, PLUGIN_AUTHOR);

    if (is_dedicated_server()) {
        log_amx("Running on a Dedicated Server");
        // server initialization here.
    } else {
        log_amx("Running on a LAN Server");
    }

    if (!ekz_config_dir_exists()) {
        new cfg_dir[128];
        ekz_get_config_dir(cfg_dir, charsmax(cfg_dir));
        mkdir(cfg_dir);
        log_amx("Configuration directory created");
    }
}
