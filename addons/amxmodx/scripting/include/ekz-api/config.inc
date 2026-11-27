/**
 * config.inc
 *
 * Easy config management for plugins.
 */

#if defined __EKZ_API_CONFIG_INCLUDED__
    #endinput
#endif
#define __EKZ_API_CONFIG_INCLUDED__

#define EKZ_CFG_DIR "easykreedz"

/**
 * Retrieves the EasyKreedz configuration directory
 *
 * @param buffer        Buffer to store dir path
 * @param len           Max buffer len
 *
 * @noreturn
 */
stock ekz_get_config_dir(buffer[], len)
{
    new cfg_dir[128];
    get_configsdir(cfg_dir, charsmax(cfg_dir));
    formatex(buffer, len, "%s/%s", cfg_dir, EKZ_CFG_DIR);
}

/**
 * Checks whether the EasyKreedz configuration directory exists.
 *
 * @return bool
 */
stock bool:ekz_config_dir_exists()
{
    new cfg_dir[128];
    ekz_get_config_dir(cfg_dir, charsmax(cfg_dir));
    if (!dir_exists(cfg_dir))
        return false;

    return true;
}
