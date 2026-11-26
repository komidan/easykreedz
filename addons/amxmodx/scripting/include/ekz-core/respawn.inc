/**
 * respawn.inc
 *
 * Prevent players from dying, respawning them at the start.
 */

#if defined __EKZ_RESPAWN_INCLUDED__
    #endinput
#endif
#define __EKZ_RESPAWN_INCLUDED__

#include <hamsandwich>
#include <ekz-api/hud>

#define TASK_PLAYER_RECOVER 2000

public OnTakeDamage(victim, inflictor, attacker, Float:damage, damagebits)
{
    if (!is_user_alive(victim)) {
        return HAM_IGNORED;
    }

    new Float:health;
    pev(victim, pev_health, health);

    if (damage >= health) {
        ekz_hud_warning(victim, "You died!");
        ExecuteHamB(Ham_Spawn, victim);
        return HAM_SUPERCEDE;
    }

    remove_task(victim + TASK_PLAYER_RECOVER);
    set_task(1.0, "TaskRecoverPlayer", victim + TASK_PLAYER_RECOVER);

    return HAM_IGNORED;
}

public TaskRecoverPlayer(taskid)
{
    new id = taskid - TASK_PLAYER_RECOVER;

    if (!is_user_connected(id)) {
        return;
    }

    if (!is_user_alive(id)) {
        return;
    }

    set_pev(id, pev_health, 100.0);
}
