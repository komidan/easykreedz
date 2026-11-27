/**
 * menus.sma
 *
 * All Menus, Handlers
 */

#include <ekz-api/menu>

stock plugin_init_menus()
{
    register_clcmd("say /ekz", "cmd_MenuShowMain");
    register_clcmd("chooseteam", "cmd_MenuShowMain");
}

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

public cmd_MenuShowRunner(id)
{
    new menu_name[32];
    formatex(menu_name, charsmax(menu_name),
        "%sRunner", EKZ_MENU_TAG
    );
    new menu = menu_create(menu_name, "MenuHandler_Runner");

    new checkpoint_text[32];
    formatex(checkpoint_text, charsmax(checkpoint_text), "Checkpoint #%d",
        g_PlayerStats[id][Runner_PlayerStats_CHECKPOINTS]
    );

    new gocheck_text[32];
    formatex(gocheck_text, charsmax(gocheck_text), "GoCheck #%d",
        g_PlayerStats[id][Runner_PlayerStats_GOCHECKS]
    );

    menu_additem(menu, checkpoint_text);
    menu_additem(menu, gocheck_text);

    menu_display(id, menu);

    return PLUGIN_HANDLED;
}

public MenuHandler_Runner(id, menu, item)
{
    if (item == MENU_EXIT) {
        menu_destroy(menu);
        return PLUGIN_HANDLED;
    }

    menu_destroy(menu);

    switch (item) {
        case 0:
            SavePosition(id);
        case 1:
            GotoPosition(id);
    }

    cmd_MenuShowRunner(id);

    return PLUGIN_HANDLED;
}

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
