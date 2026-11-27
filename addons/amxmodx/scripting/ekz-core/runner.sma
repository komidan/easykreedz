/**
 * runner.sma
 *
 * Runner/GoCheck functionality.
 */

#include <amxmodx>
#include <fakemeta>

#include <ekz-api/globals>
#include <ekz-api/hud>
#include <ekz-api/player>

enum _:RunnerData
{
    Float:RUNNER_ORIGIN[3],
    Float:RUNNER_ANGLES[3],
    bool:RUNNER_DUCKED,
    RUNNER_CHECKPOINTS,
    RUNNER_GOCHECKS,
};

new g_RunnerData[MAXPLAYERS][RunnerData];

stock SavePosition(id)
{
    if (!is_user_alive(id))
        return PLUGIN_HANDLED;

    if (!ekz_player_onground(id)) {
        ekz_hud_warning(id, "Cannot checkpoint in air!");
        return PLUGIN_HANDLED;
    }

    pev(id, pev_origin, g_RunnerData[id][RUNNER_ORIGIN]);
    pev(id, pev_v_angle, g_RunnerData[id][RUNNER_ANGLES]);
    g_RunnerData[id][RUNNER_DUCKED] = ekz_player_is_ducking(id);

    g_RunnerData[id][RUNNER_CHECKPOINTS]++;

    return PLUGIN_HANDLED;
}

stock GotoPosition(id)
{
    if (!is_user_alive(id))
        return PLUGIN_HANDLED;

    if (g_RunnerData[id][RUNNER_CHECKPOINTS] == 0) {
        ekz_hud_warning(id, "You don't have any Checkpoints!");
        return PLUGIN_HANDLED;
    }

    new Float:zero[3];

    set_pev(id, pev_punchangle, zero);
    set_pev(id, pev_fuser2, 0.0); // 0 is default stamina.
    set_pev(id, pev_velocity, zero);

    ApplyDuckState(id, g_RunnerData[id][RUNNER_DUCKED]);
    engfunc(EngFunc_SetOrigin, id, g_RunnerData[id][RUNNER_ORIGIN]);

    set_pev(id, pev_v_angle, zero);
    set_pev(id, pev_angles, g_RunnerData[id][RUNNER_ANGLES]);
    set_pev(id, pev_fixangle, 1);

    g_RunnerData[id][RUNNER_GOCHECKS]++;

    return PLUGIN_HANDLED;
}

stock ApplyDuckState(id, bool:ducked)
{
    new flags = pev(id, pev_flags);
    new Float:mins[3] = {-16.0, -16.0, -36.0};
    new Float:maxs[3] = {16.0, 16.0, 36.0};
    new Float:view[3] = {0.0, 0.0, 17.0};

    if (ducked) {
        flags |= FL_DUCKING;
        mins[2] = -18.0;
        maxs[2] = 18.0;
        view[2] = 12.0;
    } else {
        flags &= ~FL_DUCKING;
    }

    set_pev(id, pev_flags, flags);
    set_pev(id, pev_bInDuck, 0);
    set_pev(id, pev_flDuckTime, 0);
    engfunc(EngFunc_SetSize, id, mins, maxs);
    set_pev(id, pev_view_ofs, view);
}

stock Runner_ResetPlayerStats(id)
{
    g_RunnerData[id][RUNNER_CHECKPOINTS] = 0;
    g_RunnerData[id][RUNNER_GOCHECKS] = 0;

    g_RunnerData[id][RUNNER_ORIGIN][0] = 0.0;
    g_RunnerData[id][RUNNER_ORIGIN][1] = 0.0;
    g_RunnerData[id][RUNNER_ORIGIN][2] = 0.0;

    g_RunnerData[id][RUNNER_ANGLES][0] = 0.0;
    g_RunnerData[id][RUNNER_ANGLES][1] = 0.0;
    g_RunnerData[id][RUNNER_ANGLES][2] = 0.0;

    g_RunnerData[id][RUNNER_DUCKED] = false;

    return;
}
