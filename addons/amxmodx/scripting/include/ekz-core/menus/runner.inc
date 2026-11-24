/**
 * checkpoints.inc
 *
 * Checkpoint Menu
 */

#if defined __EKZ_MENU_RUNNER_INCLUDED__
    #endinput
#endif
#define __EKZ_MENU_RUNNER_INCLUDED__

#include <ekz-api/messages>

#include <ekz-core/globals>
#include <ekz-core/runner>
#include <ekz-core/timer>

public cmd_MenuShowRunner(id)
{
    new menu_name[32];
    formatex(menu_name, charsmax(menu_name),
        "%sRunner", EKZ_MENU_TAG
    );
    new menu = menu_create(menu_name, "MenuHandler_Runner");

    new checkpoint_text[32];
    formatex(checkpoint_text, charsmax(checkpoint_text), "Checkpoint #%d",
        g_PlayerStats[id][PlayerStats_CHECKPOINTS]
    );

    new gocheck_text[32];
    formatex(gocheck_text, charsmax(gocheck_text), "GoCheck #%d",
        g_PlayerStats[id][PlayerStats_GOCHECKS]
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

    switch (item) {
        case 0:
            SavePosition(id);
        case 1:
            GotoPosition(id);
    }

    cmd_MenuShowRunner(id);

    return PLUGIN_HANDLED;
}
