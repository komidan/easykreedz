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
        set_task(0.1, "TaskSendDeathMessage", victim);
        ExecuteHamB(Ham_Spawn, victim);

        return HAM_SUPERCEDE;
    }

    remove_task(victim + TASK_PLAYER_RECOVER);
    set_task(2.0, "TaskRecoverPlayer", victim + TASK_PLAYER_RECOVER);

    return HAM_HANDLED;
}

public TaskSendDeathMessage(id)
{
    if (!is_user_connected(id)) {
        return
    }

#if defined DEBUG
    new name[32];
    get_user_name(id, name, charsmax(name));
    log_amx("Player '%s' died!", name);
#endif

    ekz_hud_warning(id, "You died!");
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

#if defined DEBUG
    new name[32];
    get_user_name(id, name, charsmax(name));
    log_amx("Player '%s' was recovered!", name);
#endif

    set_pev(id, pev_health, 100.0);
}
