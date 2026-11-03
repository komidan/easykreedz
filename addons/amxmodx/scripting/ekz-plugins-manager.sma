/**
 * ekz-plugin-manager.sma
 *
 * Used to control loading and pausing of plugins from within the game.
 *
 * Requires "H" (ADMIN_CFG) flag to operate.
 */
#include <amxmodx>
#include <amxmisc>
#include <amxconst>

#include <ekz-api/menu>

#include <ekz-core/globals>
#include <ekz-core/version>
#include <ekz-plugins-manager/plugins>

#pragma semicolon 1

#define PLUGIN_NAME   "EKZ-Plugin-Manager"
#define PLUGIN_AUTHOR "komidan"

#define EKZ_PLUGINS_INI "plugins-easykreedz.ini"

enum PLUGIN_STATE {
    STATE_ENABLED = 0,
    STATE_PAUSED,
    STATE_DISABLED,
};

new PLUGIN_STATE:g_iPluginStates[sizeof(PLUGINS)];

public plugin_init()
{
    register_plugin(PLUGIN_NAME, EKZ_VERSION, PLUGIN_AUTHOR);

    register_clcmd("say /plman", "cmd_Menu", ADMIN_CFG, "Open the EKZ Plugin Manager");
}

public cmd_Menu(id, level, cid)
{
    if (!cmd_access(id, level, cid, 1)) {
        return PLUGIN_HANDLED;
    }

    ShowPluginManagerMenu(id);
    return PLUGIN_HANDLED;
}

ShowPluginManagerMenu(id)
{
    new menu_name[32];
    formatex(menu_name, charsmax(menu_name),
        "%s%s", EKZ_MENU_TAG, "Plugin Manager"
    );
    new menu = menu_create(menu_name, "menu_handler_plman");

    // handle generating the plugin list
    menu_additem(menu, "Save Options");
    menu_addblank(menu, 0);

    new text[128];
    new info[8];

    for (new i = 0; i < sizeof(PLUGINS); i++) {
        switch (g_iPluginStates[i]) {
            case STATE_ENABLED: {
                formatex(text, charsmax(text), "\w%s", PLUGINS[i]);
            }
            case STATE_PAUSED: {
                formatex(text, charsmax(text), "\y%s", PLUGINS[i]);
            }
            case STATE_DISABLED: {
                formatex(text, charsmax(text), "\r%s", PLUGINS[i]);
            }
        }

        num_to_str(i, info, charsmax(info));
        menu_additem(menu, text, info);
    }

    menu_display(id, menu);
}

public menu_handler_plman(id, menu, item)
{
    if (item == MENU_EXIT) {
        menu_destroy(menu);
        return PLUGIN_HANDLED;
    }

    new info[8];
    menu_item_getinfo(menu, item, _, info, charsmax(info));

    menu_destroy(menu);

    if (item == 0) {
        // save options...
        return PLUGIN_HANDLED;
    }

    new plugin = str_to_num(info);
    g_iPluginStates[plugin]++;

    if (g_iPluginStates[plugin] > STATE_DISABLED) {
        g_iPluginStates[plugin] = STATE_ENABLED;
    }

    ShowPluginManagerMenu(id);

    return PLUGIN_HANDLED;
}
