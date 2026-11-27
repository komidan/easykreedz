/**
 * ekz-hook.sma
 *
 * Plugin that lets people grapple around.
 */

// TODO: Add a global g_bHookUsed[MAXPLAYERS] check for each run.
// TODO: Refactor this code to separate .sma files (?)
// TODO: Color is per-player but not hookspeed or visible state. Using CVARs
//       here is not the right approach. Each player should have their own
//       values and config options.
//         - Specifically, HookSpeed and HookVisible should not be CVARs.

#include <amxmodx>
#include <cvars>
#include <fakemeta>
#include <hamsandwich>
#include <xs>

#include <ekz-api/cvar>
#include <ekz-api/globals>
#include <ekz-api/messages>
#include <ekz-api/player>
#include <ekz-api/version>

#pragma semicolon 1

#define PLUGIN_NAME   "EKZ-Hook"
#define PLUGIN_AUTHOR "komidan"

#define HOOK_MAX_DISTANCE  4096.0
#define HOOK_BEAM_TASK     3000
#define HOOK_BEAM_INTERVAL 2.0

new bool:g_bIsHooked[MAXPLAYERS];
new Float:g_vecHookPoint[MAXPLAYERS][3];

new g_iHookSprite;
new g_iHookColor[MAXPLAYERS][3];
new g_cvHookSpeed;

new g_Cvars[][CvarData] = {
    {
        "ekz_hookspeed", "512.0", FCVAR_NONE,
        "Hook Speed",
        true, 1.0, true, 2048.0
    },
};

public plugin_precache()
{
    g_iHookSprite = precache_model("sprites/laserbeam.spr");
}

public plugin_init()
{
    register_plugin(PLUGIN_NAME, EKZ_VERSION, PLUGIN_AUTHOR);

    ekz_create_cvars(g_Cvars, sizeof(g_Cvars));
    g_cvHookSpeed = get_cvar_pointer("ekz_hookspeed");

    register_forward(FM_PlayerPreThink, "OnPlayerPreThink");
    RegisterHam(Ham_Spawn, "player", "OnPlayerSpawnPost", 1);

    register_clcmd("hookcolor", "cmd_HookColor");
    register_clcmd("+hook", "cmd_HookOn");
    register_clcmd("-hook", "cmd_HookOff");

    // Set default hook color to WHITE
    for (new id = 1; id <= MaxClients; id++) {
        g_iHookColor[id][0] = 255;
        g_iHookColor[id][1] = 255;
        g_iHookColor[id][2] = 255;
    }
}

public client_disconnected(id)
{
    HookOff(id);
}

public OnPlayerSpawnPost(id)
{
    HookOff(id);
}

// ========================================================================== //
// Commands
// ========================================================================== //
public cmd_HookColor(id)
{
    if (read_argc() != 4) {
        ekz_send_console(id, "Usage: hookcolor <r:0-255> <g:0-255> <b:0-255>");
        return PLUGIN_HANDLED;
    }

    new arg[4];
    new r, g, b;

    read_argv(1, arg, charsmax(arg));
    r = str_to_num(arg);

    read_argv(2, arg, charsmax(arg));
    g = str_to_num(arg);

    read_argv(3, arg, charsmax(arg));
    b = str_to_num(arg);

    HookSetColor(id, r, g, b);

    return PLUGIN_HANDLED;
}

public cmd_HookOn(id)
{
    if (!is_user_alive(id))
        return PLUGIN_HANDLED;

    HookOn(id);

    return PLUGIN_HANDLED;
}

public cmd_HookOff(id)
{
    if (!is_user_alive(id))
        return PLUGIN_HANDLED;

    HookOff(id);

    return PLUGIN_HANDLED;
}

// ========================================================================== //
// Functions
// ========================================================================== //
stock HookSetColor(id, r, g, b)
{
    if (!ekz_player_is_indexed(id) || !is_user_connected(id))
        return;

    if (r < 0 || r > 255 ||
        g < 0 || g > 255 ||
        b < 0 || b > 255)
    {
        ekz_send_console(id, "Values outside of range.");
        return;
    }

    g_iHookColor[id][0] = r;
    g_iHookColor[id][1] = g;
    g_iHookColor[id][2] = b;
}

stock HookOn(id)
{
    if (!is_user_alive(id))
        return;
    if (g_bIsHooked[id])
        return;

    new Float:origin[3];
    new Float:view[3];
    new Float:angles[3];
    new Float:start[3];
    new Float:vforward[3]; // View Forward
    new Float:end[3];

    pev(id, pev_origin, origin);
    pev(id, pev_view_ofs, view);
    pev(id, pev_v_angle, angles);

    xs_vec_add(origin, view, start);
    angle_vector(angles, ANGLEVECTOR_FORWARD, vforward);
    xs_vec_mul_scalar(vforward, HOOK_MAX_DISTANCE, end);
    xs_vec_add(start, end, end);

    new trace = create_tr2();

    engfunc(EngFunc_TraceLine, start, end, IGNORE_MONSTERS, id, trace);

    new Float:frac;
    get_tr2(trace, TR_flFraction, frac);

    if (frac < 1.0 && frac > 0.0) {
        get_tr2(trace, TR_vecEndPos, g_vecHookPoint[id]);
        g_bIsHooked[id] = true;

        DrawHookBeam(id);
        set_task(HOOK_BEAM_INTERVAL, "TaskRefreshHookBeam",
            id + HOOK_BEAM_TASK, _, _, "b"
        );
    }

    free_tr2(trace);
}

stock HookOff(id)
{
    if (!g_bIsHooked[id])
        return;

    g_bIsHooked[id] = false;
    remove_task(id + HOOK_BEAM_TASK);
    HookKillBeam(id);
}

public OnPlayerPreThink(id)
{
    if (!is_user_alive(id))
        return FMRES_IGNORED;
    if (!g_bIsHooked[id])
        return FMRES_IGNORED;

    new Float:origin[3];
    new Float:direction[3];
    new Float:velocity[3];

    pev(id, pev_origin, origin);

    xs_vec_sub(g_vecHookPoint[id], origin, direction);

    xs_vec_normalize(direction, direction);
    xs_vec_mul_scalar(direction, get_pcvar_float(g_cvHookSpeed), velocity);

    set_pev(id, pev_velocity, velocity);

    DrawHookBeam(id);

    return FMRES_IGNORED;
}

stock DrawHookBeam(id)
{
    if (!ekz_player_is_indexed(id) || !is_user_connected(id))
        return;

    message_begin(MSG_BROADCAST, SVC_TEMPENTITY);

    write_byte(TE_BEAMENTPOINT);
    write_short(id);
    write_coord_f(g_vecHookPoint[id][0]);
    write_coord_f(g_vecHookPoint[id][1]);
    write_coord_f(g_vecHookPoint[id][2]);
    write_short(g_iHookSprite);
    write_byte(0);   // start frame
    write_byte(1);   // frame rate
    write_byte(11);  // life (1.1s, slightly longer than refresh interval)
    write_byte(10);  // width
    write_byte(0);   // noise
    write_byte(g_iHookColor[id][0]);   // red
    write_byte(g_iHookColor[id][1]);   // green
    write_byte(g_iHookColor[id][2]);   // blue
    write_byte(200); // brightness
    write_byte(0);   // scroll speed
    message_end();
}

stock HookKillBeam(id)
{
    message_begin(MSG_ALL, SVC_TEMPENTITY);
    write_byte(TE_KILLBEAM);
    write_short(id);
    message_end();
}

public TaskRefreshHookBeam(taskid)
{
    new id = taskid - HOOK_BEAM_TASK;

    if (!is_user_alive(id)) {
        HookOff(id);
        return;
    }

    DrawHookBeam(id);
}
