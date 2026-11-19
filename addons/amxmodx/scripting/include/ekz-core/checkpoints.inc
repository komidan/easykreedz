/**
 * checkpoints.inc
 *
 * Checkpoint/Gocheck implementation
 */

#if defined __EKZ_CHECKPOINTS_INCLUDED__
    #endinput
#endif
#define __EKZ_CHECKPOINTS_INCLUDED__

#include <fakemeta>

#include <ekz-api/messages>
#include <ekz-api/player>

#include <ekz-core/globals>

enum _:PlayerData
{
    Float:_ORIGIN[3],
    Float:_ANGLES[3],
    Float:_FRICTION
}

enum _:PlayerStats
{
    _CHECKPOINTS,
    _GOCHECKS
}

new Float:g_PlayerData[MAXPLAYERS][PlayerData];
new g_PlayerStats[MAXPLAYERS][PlayerStats];

SavePosition(id)
{
    if (!is_user_alive(id)) {
        return PLUGIN_HANDLED;
    }

    if (!IsPlayerOnGround(id)) {
        ekz_send_warning(id, "Cannot checkpoint in air!");
        return PLUGIN_HANDLED;
    }

    pev(id, pev_origin, g_PlayerData[id][_ORIGIN]);
    pev(id, pev_v_angle, g_PlayerData[id][_ANGLES]);
    pev(id, pev_friction, g_PlayerData[id][_FRICTION]);

    g_PlayerStats[id][_CHECKPOINTS]++;

    return PLUGIN_HANDLED;
}

GotoPosition(id)
{
    if (!is_user_alive(id)) {
        return PLUGIN_HANDLED;
    }

    new Float:zero[3] = {0.0, 0.0, 0.0};

    set_pev(id, pev_punchangle, zero);
    set_pev(id, pev_fuser2, 0); // 0 is default stamina.
    set_pev(id, pev_velocity, zero);

    engfunc(EngFunc_SetOrigin, id, g_PlayerData[id][_ORIGIN]);

    set_pev(id, pev_v_angle, zero);
    set_pev(id, pev_angles, g_PlayerData[id][_ANGLES]);
    set_pev(id, pev_fixangle, 1);

    g_PlayerStats[id][_GOCHECKS]++;

    return PLUGIN_HANDLED;
}
