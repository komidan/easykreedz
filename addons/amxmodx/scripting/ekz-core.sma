/**
 * ekz-core.sma
 *
 * Contains the classical minimum for legal Kreedz'ing.
 */
#include <amxmodx>
#include <amxmisc>

#include <ekz-core/globals>
#include <ekz-core/version>

#pragma semicolon 1

#define PLUGIN_NAME     "EKZ-Core"
#define PLUGIN_AUTHOR   "komidan"

#define ACCESS_FLAG ADMIN_CFG;

public plugin_cfg()
{
    return PLUGIN_HANDLED;
}

public plugin_init()
{
    register_plugin(PLUGIN_NAME, EKZ_VERSION, PLUGIN_AUTHOR, EKZ_GITHUB);

    if (is_dedicated_server()) {
        log_amx("Running on a Dedicated Server");
        // server initialization here.
    } else {
        log_amx("Running on a LAN Server");
    }

    // Verify configuration directory exists for other plugins.
    new cfg_dir[128];
    new ekz_cfg_dir[128];
    get_configsdir(cfg_dir, charsmax(cfg_dir));
    formatex(ekz_cfg_dir, charsmax(ekz_cfg_dir), "%s/%s", cfg_dir, EKZ_CFG_DIR);

    if (!dir_exists(ekz_cfg_dir)) {
        log_amx("Created directory %s", ekz_cfg_dir);
        mkdir(ekz_cfg_dir);
    }
}
