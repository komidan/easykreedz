/**
 * respawn.sma
 *
 * Handles recovering HP after taking damage and instantly respawning after
 * taking damage >= health.
 */

#include <amxmodx>
#include <fakemeta>
#include <fun>
#include <hamsandwich>

#include <ekz-api/hud>

#define TASK_PLAYER_RECOVER 2000
#define TASK_DEATH_MESSAGE  2100

stock PluginInit_Respawn()
{
    register_concmd("kill", "cmd_KillPlayer");
    register_clcmd("say /kill", "cmd_KillPlayer");

    RegisterHam(Ham_TakeDamage, "player", "OnTakeDamage");
}

stock ClientDisconnected_Respawn(id)
{
    remove_task(id + TASK_PLAYER_RECOVER);
    remove_task(id + TASK_DEATH_MESSAGE);
}

public cmd_KillPlayer(id)
{
    if (!is_user_alive(id))
        return PLUGIN_HANDLED;

    PlayerKill(id);

    return PLUGIN_HANDLED;
}

stock PlayerKill(id)
{
    if (!is_user_alive(id))
        return;

    remove_task(id + TASK_PLAYER_RECOVER);
    remove_task(id + TASK_DEATH_MESSAGE);

    set_task(0.1, "TaskSendDeathMessage", id + TASK_DEATH_MESSAGE);

    ExecuteHamB(Ham_Spawn, id);
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

        PlayerKill(victim);
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
