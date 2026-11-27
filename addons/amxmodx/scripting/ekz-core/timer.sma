/**
 * timer.sma
 *
 * Timer functionality.
 */

#include <amxmodx>
#include <engine>
#include <hamsandwich>

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
new const g_szStartTimerTargets[][] = {
    "counter_start_button",
};

// A list of possible stop timer classnames.
new const g_szEndTimerTargets[][] = {
    "counter_stop_button",
};

// Use elapsed time as the core mechanic of timing.
new Float:g_fStartTime[MAXPLAYERS];
new TimerState:g_eTimerState[MAXPLAYERS];

// Holds the Entity IDs of the start & end timer funcs.
new g_iStartTimerId;
new g_iEndTimerId;

stock PluginInit_Timer()
{
    register_clcmd("say /cancel", "cmd_CancelTimer");

    RegisterHam(Ham_Use, "func_button", "OnButtonUse", 0);

    TimerInitEntities();
}

public ClientPutInServer_Timer(id)
{
    g_eTimerState[id] = TIMER_INACTIVE;
    Runner_ResetPlayerStats(id);
}

public ClientDisconnected_Timer(id)
{
    g_eTimerState[id] = TIMER_INACTIVE;
    Runner_ResetPlayerStats(id);
}

public cmd_TimerCancel(id)
{
    if (!is_user_alive(id))
        return PLUGIN_HANDLED;

    TimerCancel(id);

    return PLUGIN_HANDLED;
}

stock TimerType:GetTimerNameType(const name[])
{
    for (new i = 0; i < sizeof(g_szStartTimerTargets); i++) {
        if (equal(name, g_szStartTimerTargets[i])) {
            return TIMER_START;
        }
    }

    for (new i = 0; i < sizeof(g_szEndTimerTargets); i++) {
        if (equal(name, g_szEndTimerTargets[i])) {
            return TIMER_END;
        }
    }

    return TIMER_NONE;
}

stock TimerType:GetTimerEntityType(ent)
{
    new name[64];
    entity_get_string(ent, EV_SZ_targetname, name, charsmax(name));

    new TimerType:type = GetTimerNameType(name);
    if (type != TIMER_NONE)
        return type;

    entity_get_string(ent, EV_SZ_target, name, charsmax(name));
    return GetTimerNameType(name);
}

stock TimerInitEntities()
{
    new ent = -1;

    while ((ent = find_ent_by_class(ent, "func_button")) > 0) {
        switch (GetTimerEntityType(ent)) {
            case TIMER_START: g_iStartTimerId = ent;
            case TIMER_END: g_iEndTimerId = ent;
        }
    }

    if (!g_iStartTimerId)
        log_amx("No start button found!");
    if (!g_iEndTimerId)
        log_amx("No end button found!");
}

// Ham_Use
// https://amxmodx.org/api/ham_const
public OnButtonUse(ent, caller, activator, use_type, Float:value)
{
    if (!is_user_alive(activator) && ekz_player_is_indexed(activator))
        return HAM_IGNORED;

    if (ent == g_iStartTimerId)
        TimerStart(activator);
    else if (ent == g_iEndTimerId)
        TimerEnd(activator);

    return HAM_IGNORED;
}

// register some way to see this
stock TimerStart(id)
{
    g_eTimerState[id] = TIMER_ACTIVE;
    g_fStartTime[id] = get_gametime();

    ekz_send_chat(id, "Timer Started");

    Runner_ResetPlayerStats(id);
    cmd_MenuShowRunner(id);
}

stock TimerCancel(id)
{
    g_eTimerState[id] = TIMER_INACTIVE;

    ekz_send_chat(id, "Timer cancelled!");
    Runner_ResetPlayerStats(id);
}

stock TimerEnd(id)
{
    if (g_eTimerState[id] == TIMER_INACTIVE) {
        ekz_send_chat(id, "Timer not started!");
        return;
    }
    g_eTimerState[id] = TIMER_INACTIVE;

    new name[32], mapname[64], time[32];
    get_user_name(id, name, charsmax(name));
    get_mapname(mapname, charsmax(mapname));
    ekz_format_gametime(GetElapsed(id), time, charsmax(time));

#if defined SERVER
    ekz_send_chat_all("Player ^4%s ^1finished ^4%s ^1in ^5%s^1",
        name, mapname, time
    );
#else
    ekz_send_chat(id, "Player ^4%s ^1finished ^4%s ^1in ^5%s^1",
        name, mapname, time
    );
#endif

    Runner_ResetPlayerStats(id);
}

stock Float:GetElapsed(id)
{
    return get_gametime() - g_fStartTime[id];
}
