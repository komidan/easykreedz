/**
 * checkpoints.inc
 *
 * Checkpoint Menu
 */

#if defined __EKZ_MENU_RUNNER_INCLUDED__
    #endinput
#endif
#define __EKZ_MENU_RUNNER_INCLUDED__

#include <ekz-api/menu>
#include <ekz-api/messages>

#include <ekz-core/runner>
#include <ekz-core/timer>

public cmd_MenuShowRunner(id)
{
    new menu_name[32];
    formatex(menu_name, charsmax(menu_name),
        "%sRunner", EKZ_MENU_TAG
    );
    new menu = menu_create(menu_name, "MenuHandler_Runner");

    menu_additem(menu, "Checkpoint");
    menu_additem(menu, "GoCheck");

    menu_addblank(menu);

    new stats[32];
    formatex(stats, charsmax(stats), "\r%d \dCP \r%d \dGC",
        g_PlayerStats[id][PlayerStats_CHECKPOINTS],
        g_PlayerStats[id][PlayerStats_GOCHECKS]
    );
    menu_addtext(menu, stats);

    menu_display(id, menu);

    return PLUGIN_HANDLED;
}

public MenuHandler_Runner(id, menu, item)
{
    if (item == MENU_EXIT) {
        menu_destroy(menu);
        return PLUGIN_HANDLED;
    }

    switch (item) {
        case 0:
            SavePosition(id);
        case 1:
            GotoPosition(id);
    }

    cmd_MenuShowRunner(id);

    return PLUGIN_HANDLED;
}
