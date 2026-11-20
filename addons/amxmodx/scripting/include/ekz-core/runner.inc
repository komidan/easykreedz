/**
 * checkpoints.inc
 *
 * Checkpoint/Gocheck implementation
 */

#if defined __EKZ_RUNNER_INCLUDED__
    #endinput
#endif
#define __EKZ_RUNNER_INCLUDED__

#include <fakemeta>

#include <ekz-api/messages>
#include <ekz-api/player>

#include <ekz-core/globals>

enum _:EKZ_Runner_PlayerData
{
    Float:PlayerData_ORIGIN[3],
    Float:PlayerData_ANGLES[3],
}

enum _:EKZ_Runner_PlayerStats
{
    PlayerStats_CHECKPOINTS,
    PlayerStats_GOCHECKS
}

new Float:g_PlayerData[MAXPLAYERS][EKZ_Runner_PlayerData];
new g_PlayerStats[MAXPLAYERS][EKZ_Runner_PlayerStats];

stock SavePosition(id)
{
    if (!is_user_alive(id)) {
        return PLUGIN_HANDLED;
    }

    if (!IsPlayerOnGround(id)) {
        ekz_send_warning(id, "Cannot checkpoint in air!");
        return PLUGIN_HANDLED;
    }

    pev(id, pev_origin, g_PlayerData[id][PlayerData_ORIGIN]);
    pev(id, pev_v_angle, g_PlayerData[id][PlayerData_ANGLES]);

    g_PlayerStats[id][PlayerStats_CHECKPOINTS]++;

    return PLUGIN_HANDLED;
}

stock GotoPosition(id)
{
    if (!is_user_alive(id)) {
        return PLUGIN_HANDLED;
    }

    if (g_PlayerStats[id][PlayerStats_CHECKPOINTS] == 0) {
        ekz_send_warming(id, "You don't have any checkpoints!");
        return PLUGIN_HANDLED;
    }

    new Float:zero[3] = {0.0, 0.0, 0.0};

    set_pev(id, pev_punchangle, zero);
    set_pev(id, pev_fuser2, 0); // 0 is default stamina.
    set_pev(id, pev_velocity, zero);

    engfunc(EngFunc_SetOrigin, id, g_PlayerData[id][PlayerData_ORIGIN]);

    set_pev(id, pev_v_angle, zero);
    set_pev(id, pev_angles, g_PlayerData[id][PlayerData_ANGLES]);
    set_pev(id, pev_fixangle, 1);

    g_PlayerStats[id][PlayerStats_GOCHECKS]++;

    return PLUGIN_HANDLED;
}
