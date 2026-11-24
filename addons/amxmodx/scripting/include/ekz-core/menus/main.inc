/**
 * main.inc
 *
 * Main Menu
 */

#if defined __EKZ_MENU_MAIN_INCLUDED__
    #endinput
#endif
#define __EKZ_MENU_MAIN_INCLUDED__

#include <ekz-api/menu>
#include <ekz-api/messages>

#include <ekz-core/menus/runner>
#include <ekz-core/menus/settings>

public cmd_MenuShowMain(id)
{
    new menu_name[32];
    formatex(menu_name, charsmax(menu_name),
        "%s%s", EKZ_MENU_TAG, "Main Menu"
    );
    new menu = menu_create(menu_name, "MenuHandler_Main");

    menu_additem(menu, "Runner");
    menu_additem(menu, "Settings");
#if !defined SERVER_BUILD
    menu_additem(menu, "Plugin Manager");
#endif
    menu_display(id, menu);

    return PLUGIN_HANDLED;
}

public MenuHandler_Main(id, menu, item)
{
    if (item == MENU_EXIT) {
        menu_destroy(menu);
        return PLUGIN_HANDLED;
    }

    switch (item) {
        case 0: // Runner Menu
            cmd_MenuShowRunner(id);
        case 1: // Settings
            cmd_MenuShowSettings(id);
#if !defined SERVER_BUILD
        case 2: // Plugin Manager
            client_cmd(id, "say /plman");
#endif
        default:
            cmd_MenuShowMain(id);
    }

    menu_destroy(menu);

    return PLUGIN_HANDLED;
}
