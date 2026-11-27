/**
 * Runner.sma
 *
 * Runner/GoCheck functionality.
 */

#include <amxmodx>
#include <fakemeta>

#include <ekz-api/globals>
#include <ekz-api/hud>
#include <ekz-api/player>

enum _:EKZ_RunnerData
{
    Float:Runner_ORIGIN[3],
    Float:Runner_ANGLES[3],
    bool:Runner_DUCKED,
    Runner_CHECKPOINTS,
    Runner_GOCHECKS,
};

new g_RunnerData[MAXPLAYERS][EKZ_RunnerData];

stock SavePosition(id)
{
    if (!is_user_alive(id)) {
        return PLUGIN_HANDLED;
    }

    if (!ekz_player_onground(id)) {
        ekz_hud_warning(id, "Cannot checkpoint in air!");
        return PLUGIN_HANDLED;
    }

    pev(id, pev_origin, g_RunnerData[id][Runner_ORIGIN]);
    pev(id, pev_v_angle, g_RunnerData[id][Runner_ANGLES]);

    g_RunnerData[id][Runner_CHECKPOINTS]++;

    return PLUGIN_HANDLED;
}

stock GotoPosition(id)
{
    if (!is_user_alive(id))
        return PLUGIN_HANDLED;

    if (g_RunnerData[id][Runner_CHECKPOINTS] == 0) {
        ekz_hud_warning(id, "You don't have any Checkpoints!");
        return PLUGIN_HANDLED;
    }

    new Float:zero[3] = {0.0, 0.0, 0.0};

    set_pev(id, pev_punchangle, zero);
    set_pev(id, pev_fuser2, 0); // 0 is default stamina.
    set_pev(id, pev_velocity, zero);

    engfunc(EngFunc_SetOrigin, id, g_RunnerData[id][Runner_ORIGIN]);

    set_pev(id, pev_v_angle, zero);
    set_pev(id, pev_angles, g_RunnerData[id][Runner_ANGLES]);
    set_pev(id, pev_fixangle, 1);

    g_RunnerData[id][Runner_GOCHECKS]++;

    return PLUGIN_HANDLED;
}

stock Runner_ResetPlayerStats(id)
{
    g_RunnerData[id][Runner_CHECKPOINTS] = 0;
    g_RunnerData[id][Runner_GOCHECKS] = 0;

    g_RunnerData[id][Runner_ORIGIN][0] = 0.0;
    g_RunnerData[id][Runner_ORIGIN][1] = 0.0;
    g_RunnerData[id][Runner_ORIGIN][2] = 0.0;

    g_RunnerData[id][Runner_ANGLES][0] = 0.0;
    g_RunnerData[id][Runner_ANGLES][1] = 0.0;
    g_RunnerData[id][Runner_ANGLES][2] = 0.0;

    return;
}
