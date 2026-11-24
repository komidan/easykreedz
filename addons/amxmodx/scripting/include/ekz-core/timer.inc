/**
 * timer.inc
 *
 * Timer functionality.
 */

#if defined __EKZ_TIMER_INCLUDED__
    #endinput
#endif
#define __EKZ_TIMER_INCLUDED__

#include <engine>

#include <ekz-api/messages>

#include <ekz-core/globals>

enum TimerState {
    TIMER_ACTIVE,
    TIMER_STOPPED
};

enum TimerType {
    TIMER_NONE,
    TIMER_START,
    TIMER_END
};

// A list of possible start timer classnames.
new g_szStartTimerTargets[1][] = {
    "counter_start_button",
}

// A list of possible stop timer classnames.
new g_szEndTimerTargets[1][] = {
    "counter_stop_button",
}

// Use elapsed time as the core mechanic of timing.
new Float:g_iStartTime[MAXPLAYERS];
new TimerState:g_eTimerState[MAXPLAYERS];

new g_iStartTimerId;
new g_iStopTimerId;

TimerType:get_timer_type(const szTarget[])
{
    for (new i = 0; i < sizeof(g_szStartTimerTargets); i++) {
        if (equal(szTarget, g_szStartTimerTargets[i])) {
            return TIMER_START;
        }
    }

    for (new i = 0; i < sizeof(g_szEndTimerTargets); i++) {
        if (equal(szTarget, g_szEndTimerTargets[i])) {
            return TIMER_END;
        }
    }

    return TIMER_NONE;
}

public init_entities()
{
    new n = entity_count();
    new target[64];
    new TimerType:eType;

    for (new i = 0; i < n; i++) {
        entity_get_string(i, EV_SZ_targetname, target, charsmax(target));
        eType = get_timer_type(target);

        if (eType == TIMER_NONE) {
            entity_get_string(i, EV_SZ_target, target, charsmax(target));
            eType = get_timer_type(target);
        }

        switch (eType) {
            case TIMER_START: g_iStartTimerId = i;
            case TIMER_END: g_iStopTimerId = i;
        }
    }

    return PLUGIN_HANDLED;
}

public OnButtonUse(ent, caller, activator, use_type, Float:value)
{
    if (!is_user_alive(activator))
    {
        return HAM_IGNORED;
    }

    if (ent == g_iStartTimerId)
    {
        StartTimer(activator);
    } else if (ent == g_iStopTimerId) {
        StopTimer(activator);
    }

    return HAM_IGNORED;
}

// register some way to see this
StartTimer(id)
{
    g_iStartTime[id] = get_gametime();
    ekz_send_chat(id, "Timer Started");
    g_eTimerState[id] = TIMER_ACTIVE;
}

StopTimer(id)
{
    ekz_send_chat(id, "Timer Stopped");
    g_eTimerState[id] = TIMER_STOPPED;
}
