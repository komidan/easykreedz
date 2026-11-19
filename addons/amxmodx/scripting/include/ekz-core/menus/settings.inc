/**
 * settings.inc
 *
 * Settings Menu
 */

#if defined __EKZ_MENU_SETTINGS_INCLUDED__
    #endinput
#endif
#define __EKZ_MENU_SETTINGS_INCLUDED__

public cmd_MenuShowSettings(id)
{
    new menu_name[32];
    formatex(menu_name, charsmax(menu_name),
        "%s%s", EKZ_MENU_TAG, "Settings"
    );
    new menu = menu_create(menu_name, "MenuHandler_Settings");

    menu_additem(menu, "Work in Progress.");

    menu_display(id, menu);

    return PLUGIN_HANDLED;
}

public MenuHandler_Settings(id, menu, item)
{
    if (item == MENU_EXIT) {
        menu_destroy(menu);
        return PLUGIN_HANDLED;
    }

    switch (item) {
        default:
            ekz_send_chat(id, "settings!");
    }

    menu_destroy(menu);

    return PLUGIN_HANDLED;
}
