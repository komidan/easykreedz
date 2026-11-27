/**
 * timer.sma
 *
 * Timer functionality.
 */

#include <amxmodx>
#include <engine>

#include <ekz-api/globals>
#include <ekz-api/messages>
#include <ekz-api/time>

enum TimerState {
    TIMER_INACTIVE,
    TIMER_ACTIVE,
    TIMER_PAUSED
};

enum TimerType {
    TIMER_NONE,
    TIMER_START,
    TIMER_END
};

// A list of possible start timer classnames.
new g_szStartTimerTargets[1][] = {
    "counter_start_button",
};

// A list of possible stop timer classnames.
new g_szEndTimerTargets[1][] = {
    "counter_stop_button",
};

// Use elapsed time as the core mechanic of timing.
new Float:g_fStartTime[MAXPLAYERS];
new TimerState:g_eTimerState[MAXPLAYERS];

// Holds the Entity IDs of the start & end timer funcs.
new g_iStartTimerId;
new g_iStopTimerId;

stock plugin_init_timer()
{
    init_entities();
    register_clcmd("say /cancel", "cmd_CancelTimer");
    RegisterHam(Ham_Use, "func_button", "OnButtonUse", 0);
}

public client_putinserver_timer(id)
{
    g_eTimerState[id] = TIMER_INACTIVE;
    Runner_ResetPlayerStats(id);

    return;
}

stock init_entities()
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
        return HAM_IGNORED;

    if (ent == g_iStartTimerId) {
        StartTimer(activator);
    } else if (ent == g_iStopTimerId) {
        FinishTimer(activator);
    }

    return HAM_IGNORED;
}

stock TimerType:get_timer_type(const szTarget[])
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

// register some way to see this
stock StartTimer(id)
{
    g_eTimerState[id] = TIMER_ACTIVE;

    g_fStartTime[id] = get_gametime();
    Runner_ResetPlayerStats(id);

#if defined DEBUG
    ekz_send_chat(id, "START TIME: %f", g_fStartTime[id]);
#endif

    ekz_send_chat(id, "Timer Started");

    return;
}

public cmd_CancelTimer(id)
{
    if (!is_user_alive(id))
        return PLUGIN_HANDLED;

    g_eTimerState[id] = TIMER_INACTIVE;

    ekz_send_chat(id, "Timer stopped!");
    Runner_ResetPlayerStats(id);

    return PLUGIN_HANDLED;
}

stock FinishTimer(id)
{
    if (g_eTimerState[id] == TIMER_INACTIVE) {
        ekz_send_chat(id, "Timer not started!");
        return;
    }
    g_eTimerState[id] = TIMER_INACTIVE;

    Runner_ResetPlayerStats(id);

#if defined DEBUG
    ekz_send_chat(id, "END TIME: %f", get_gametime());
    ekz_send_chat(id, "ELAPSED: %f", GetTime(id));
#endif

    new time[32];
    new mapname[64];
    get_mapname(mapname, charsmax(mapname));

    ekz_format_gametime(GetTime(id), time, charsmax(time));
    ekz_send_chat(id, "Finished ^4%s ^1in ^5%s^1",
        mapname, time
    );

    return;
}

stock Float:GetTime(id)
{
    return get_gametime() - g_fStartTime[id];
}
