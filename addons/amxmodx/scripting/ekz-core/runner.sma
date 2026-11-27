/**
 * Runner.sma
 *
 * Runner/GoCheck functionality.
 */

#include <fakemeta>

#include <ekz-api/globals>
#include <ekz-api/hud>
#include <ekz-api/player>

enum _:EKZ_Runner_PlayerData
{
    Float:Runner_PlayerData_ORIGIN[3],
    Float:Runner_PlayerData_ANGLES[3],
};

enum _:EKZ_Runner_PlayerStats
{
    Runner_PlayerStats_CHECKPOINTS,
    Runner_PlayerStats_GOCHECKS
};

new Float:g_PlayerData[MAXPLAYERS][EKZ_Runner_PlayerData];
new g_PlayerStats[MAXPLAYERS][EKZ_Runner_PlayerStats];

stock SavePosition(id)
{
    if (!is_user_alive(id)) {
        return PLUGIN_HANDLED;
    }

    if (!ekz_player_onground(id)) {
        ekz_hud_warning(id, "Cannot checkpoint in air!");
        return PLUGIN_HANDLED;
    }

    pev(id, pev_origin, g_PlayerData[id][Runner_PlayerData_ORIGIN]);
    pev(id, pev_v_angle, g_PlayerData[id][Runner_PlayerData_ANGLES]);

    g_PlayerStats[id][Runner_PlayerStats_CHECKPOINTS]++;

    return PLUGIN_HANDLED;
}

stock GotoPosition(id)
{
    if (!is_user_alive(id)) {
        return PLUGIN_HANDLED;
    }

    if (g_PlayerStats[id][Runner_PlayerStats_CHECKPOINTS] == 0) {
        ekz_hud_warning(id, "You don't have any Runner!");
        return PLUGIN_HANDLED;
    }

    new Float:zero[3] = {0.0, 0.0, 0.0};

    set_pev(id, pev_punchangle, zero);
    set_pev(id, pev_fuser2, 0); // 0 is default stamina.
    set_pev(id, pev_velocity, zero);

    engfunc(EngFunc_SetOrigin, id, g_PlayerData[id][Runner_PlayerData_ORIGIN]);

    set_pev(id, pev_v_angle, zero);
    set_pev(id, pev_angles, g_PlayerData[id][Runner_PlayerData_ANGLES]);
    set_pev(id, pev_fixangle, 1);

    g_PlayerStats[id][Runner_PlayerStats_GOCHECKS]++;

    return PLUGIN_HANDLED;
}

stock Runner_ResetPlayerStats(id)
{
    g_PlayerStats[id][Runner_PlayerStats_CHECKPOINTS] = 0;
    g_PlayerStats[id][Runner_PlayerStats_GOCHECKS] = 0;

    g_PlayerData[id][Runner_PlayerData_ORIGIN][0] = 0.0;
    g_PlayerData[id][Runner_PlayerData_ORIGIN][1] = 0.0;
    g_PlayerData[id][Runner_PlayerData_ORIGIN][2] = 0.0;

    g_PlayerData[id][Runner_PlayerData_ANGLES][0] = 0.0;
    g_PlayerData[id][Runner_PlayerData_ANGLES][1] = 0.0;
    g_PlayerData[id][Runner_PlayerData_ANGLES][2] = 0.0;

    // Refresh Menu, showing zero Runner/gochecks.
    // Also serves to open the menu when starting a run.
    cmd_MenuShowRunner(id);

    return;
}
