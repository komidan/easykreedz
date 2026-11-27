/**
 * ekz-plugin-manager.sma
 *
 * Used to control loading and pausing of plugins from within the game.
 *
 * Requires "H" (ADMIN_CFG) flag to operate.
 */

#include <amxconst>
#include <amxmisc>
#include <amxmodx>

#include <ekz-api/globals>
#include <ekz-api/menu>
#include <ekz-api/messages>
#include <ekz-api/version>

#pragma semicolon 1

#define PLUGIN_NAME   "EKZ-Plugin-Manager"
#define PLUGIN_AUTHOR "komidan"

enum PLUGIN_STATE {
    STATE_ENABLED = 0,
    STATE_PAUSED,
    STATE_UNLOADED,
    STATE_DISABLED
};

new const PLUGINS[][] = {
    // 7yPh00N's plugins for testing.
    "mhud_speed.amxx",
    "mhud_menu.amxx",
    "input_overlay.amxx",

    "ekz-hook.amxx"
};

new PLUGIN_STATE:g_iPluginStates[sizeof(PLUGINS)];
new PLUGIN_STATE:g_iPluginSavedStates[sizeof(PLUGINS)];

public plugin_init()
{
    register_plugin(PLUGIN_NAME, EKZ_VERSION, PLUGIN_AUTHOR);

    register_clcmd("say /plman", "cmd_Menu", ADMIN_CFG,
        "Open the EKZ Plugin Manager"
    );

    ekz_chat_init();
}

public cmd_Menu(id, level, cid)
{
    if (!cmd_access(id, level, cid, 1)) {
        return PLUGIN_HANDLED;
    }

    MenuShowPluginManager(id);
    return PLUGIN_HANDLED;
}

MenuShowPluginManager(id)
{
    new menu_name[32];
    formatex(menu_name, charsmax(menu_name),
        "%s%s", EKZ_MENU_TAG, "Plugin Manager"
    );
    new menu = menu_create(menu_name, "MenuHandler_PluginManager");

    // handle generating the plugin list
    menu_additem(menu, "Save Options");
    menu_addblank(menu, 0);

    new name[128], pstate[32], final[64], info[8];

    for (new i = 0; i < sizeof(PLUGINS); i++) {
        switch (g_iPluginStates[i]) {
            case STATE_ENABLED: {
                formatex(name, charsmax(name), "\w%s\w", PLUGINS[i]);
            }
            case STATE_PAUSED: {
                formatex(name, charsmax(name), "\y%s\w", PLUGINS[i]);
            }
            case STATE_UNLOADED: {
                formatex(name, charsmax(name), "\r%s\w", PLUGINS[i]);
            }
            case STATE_DISABLED: {
                formatex(name, charsmax(name), "\d%s\w", PLUGINS[i]);
            }
        }

        switch (g_iPluginSavedStates[i]) {
            case STATE_ENABLED: {
                formatex(pstate, charsmax(pstate), "[E]");
            }
            case STATE_PAUSED: {
                formatex(pstate, charsmax(pstate), "[P]");
            }
            case STATE_UNLOADED: {
                formatex(pstate, charsmax(pstate), "[U]");
            }
            case STATE_DISABLED: {
                formatex(pstate, charsmax(pstate), "[D]");
            }
        }

        formatex(final, charsmax(final), "%s %s", pstate, name);
        num_to_str(i, info, charsmax(info));
        menu_additem(menu, final, info);
    }

    menu_display(id, menu);
}

public MenuHandler_PluginManager(id, menu, item)
{
    if (item == MENU_EXIT) {
        menu_destroy(menu);
        return PLUGIN_HANDLED;
    }

    new info[8];
    menu_item_getinfo(menu, item, _, info, charsmax(info));
    new plugin = str_to_num(info);

    menu_destroy(menu);

    if (item != 0) {
        g_iPluginStates[plugin]++;

        // NOTE: Should this be swapped for modulos?
        // Wrap back to STATE_ENABLED
        if (g_iPluginStates[plugin] > STATE_DISABLED) {
            g_iPluginStates[plugin] = STATE_ENABLED;
        }

        MenuShowPluginManager(id);
        return PLUGIN_HANDLED;
    }

    for (new i = 0; i < sizeof(PLUGINS); i++) {
        // For reference on the pausing flags:
        // https://www.amxmodx.org/api/amxmodx/pause
        // https://www.amxmodx.org/api/amxmodx/unpause
        switch (g_iPluginStates[i]) {
            case STATE_ENABLED: {
                unpause("ac", PLUGINS[i]);
                g_iPluginSavedStates[i] = STATE_ENABLED;
            }
            case STATE_PAUSED: {
                pause("ac", PLUGINS[i]);
                g_iPluginSavedStates[i] = STATE_PAUSED;
            }
            case STATE_UNLOADED: {
                pause("dc", PLUGINS[i]);
                g_iPluginSavedStates[i] = STATE_UNLOADED;
            }
            case STATE_DISABLED: {
                g_iPluginSavedStates[i] = STATE_DISABLED;
                // change the file itself to stop loading it
            }
        }
    }

    ekz_send_chat(id, "Ran plugin settings.");
    MenuShowPluginManager(id);

    return PLUGIN_HANDLED;
}
