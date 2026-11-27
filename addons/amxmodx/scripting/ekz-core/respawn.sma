/**
 * respawn.sma
 *
 * Handles recovering HP after taking damage and instantly respawning after
 * taking damage >= health.
 */

#include <fun>
#include <hamsandwich>

#define TASK_PLAYER_RECOVER 2000

stock plugin_init_respawn()
{
    RegisterHam(Ham_TakeDamage, "player", "OnTakeDamage");
}

// Ham_TakeDamage
// https://www.amxmodx.org/api/ham_const
public OnTakeDamage(victim, inflictor, attacker, Float:damage, damagebits)
{
    if (!is_user_alive(victim))
        return HAM_IGNORED;
    if (get_user_godmode(victim))
        return HAM_IGNORED;

    new Float:health;
    pev(victim, pev_health, health);

    if (damage >= health ) {
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
    if (!is_user_connected(id))
        return PLUGIN_HANDLED;

#if defined DEBUG
    new name[32];
    get_user_name(id, name, charsmax(name));
    log_amx("Player '%s' died!", name);
#endif

    ekz_hud_warning(id, "You died!");

    return PLUGIN_HANDLED;
}

public TaskRecoverPlayer(taskid)
{
    new id = taskid - TASK_PLAYER_RECOVER;

    if (!is_user_connected(id))
        return PLUGIN_HANDLED;
    if (!is_user_alive(id))
        return PLUGIN_HANDLED;

#if defined DEBUG
    new name[32];
    get_user_name(id, name, charsmax(name));
    log_amx("Player '%s' was recovered!", name);
#endif

    set_pev(id, pev_health, 100.0);

    return PLUGIN_HANDLED;
}
