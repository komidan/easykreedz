/**
 * menus.sma
 *
 * All Menus, Handlers
 */

#include <amxmodx>

#include <ekz-api/menu>
#include <ekz-api/messages>

stock PluginInit_Menus()
{
    register_clcmd("say /ekz", "cmd_MenuShowMain");
    register_clcmd("chooseteam", "cmd_MenuShowMain");
    register_clcmd("buyammo1", "cmd_MenuShowRunner");
    register_clcmd("say /settings", "cmd_MenuShowSettings");
}

public cmd_MenuShowMain(id)
{
    if (!is_user_alive(id))
        return PLUGIN_HANDLED;

    MenuShowMain(id);

    return PLUGIN_HANDLED;
}

stock MenuShowMain(id)
{
    new menu_name[32];
    formatex(menu_name, charsmax(menu_name),
        "%s%s", EKZ_MENU_TAG, "Main Menu"
    );
    new menu = menu_create(menu_name, "MenuHandler_Main");

    menu_additem(menu, "Runner");
    menu_additem(menu, "Settings");

    if (ekz_player_has_access(id, ADMIN_CFG))
        menu_additem(menu, "Plugin Manager");

    menu_display(id, menu);
}

public MenuHandler_Main(id, menu, item)
{
    if (item == MENU_EXIT) {
        menu_destroy(menu);
        return PLUGIN_HANDLED;
    }

    switch (item) {
        case 0: // Runner Menu
            MenuShowRunner(id);
        case 1: // Settings
            MenuShowSettings(id);
        case 2: // Plugin Manager
            client_cmd(id, "say /plman");
        default:
            cmd_MenuShowMain(id);
    }

    menu_destroy(menu);

    return PLUGIN_HANDLED;
}

public cmd_MenuShowRunner(id)
{
    if (!is_user_alive(id))
        return PLUGIN_HANDLED;

    MenuShowRunner(id);

    return PLUGIN_HANDLED;
}

stock MenuShowRunner(id)
{
    new menu_name[32];
    formatex(menu_name, charsmax(menu_name),
        "%sRunner", EKZ_MENU_TAG
    );
    new menu = menu_create(menu_name, "MenuHandler_Runner");

    new checkpoint_text[32];
    formatex(checkpoint_text, charsmax(checkpoint_text), "Checkpoint #%d",
        g_RunnerData[id][RUNNER_CHECKPOINTS]
    );

    new gocheck_text[32];
    formatex(gocheck_text, charsmax(gocheck_text), "GoCheck #%d",
        g_RunnerData[id][RUNNER_GOCHECKS]
    );

    menu_additem(menu, checkpoint_text);
    menu_additem(menu, gocheck_text);

    menu_display(id, menu);
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
    if (!is_user_alive(id))
        return PLUGIN_HANDLED;

    MenuShowSettings(id);

    return PLUGIN_HANDLED;
}

stock MenuShowSettings(id)
{
    new menu_name[32];
    formatex(menu_name, charsmax(menu_name),
        "%s%s", EKZ_MENU_TAG, "Settings"
    );
    new menu = menu_create(menu_name, "MenuHandler_Settings");

    menu_additem(menu, "Work in Progress.");

    menu_display(id, menu);
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
