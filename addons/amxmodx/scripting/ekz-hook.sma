/**
 * ekz-hook.sma
 *
 * Plugin that lets people grapple around.
 */

// TODO: Add a Sprite for the 'Hook'
// TODO: Color the sprite optionally using a menu or hookcolor(r,g,b) command.

#include <amxmodx>
#include <fakemeta>
#include <xs>

#include <ekz-api/cvar>
#include <ekz-api/messages>

#include <ekz-core/globals>
#include <ekz-core/version>

#define PLUGIN_NAME "EKZ-Hook"
#define PLUGIN_AUTHOR "komidan"

// This was arbitrarily picked. It could change, and I've tested with >10000,
// no idea if it can cause issues.
#define HOOK_MAX_DISTANCE 4096.0

new bool:g_bIsHooked[MAXPLAYERS];
new Float:g_vecHookPoint[MAXPLAYERS][3];
new g_cvHookSpeed;

new g_Cvars[][CvarData] = {
    { "ekz_hookspeed", "1", FCVAR_NONE, "Hook Speed", true, 1.0, true, 2048.0 },
};

public plugin_init()
{
    register_plugin(PLUGIN_NAME, EKZ_VERSION, PLUGIN_AUTHOR);

    CreateCvars(g_Cvars, sizeof(g_Cvars));
    g_cvHookSpeed = get_cvar_pointer("ekz_hookspeed");

    register_forward(FM_PlayerPreThink, "OnPlayerPreThink");

    register_clcmd("/hookspeed", "cmd_HookSpeed");
    // register_clcmd("/hookcolor", "cmd_HookColor");

    register_clcmd("+hook", "cmd_HookOn");
    register_clcmd("-hook", "cmd_HookOff");
}

public client_disconnected(id)
{
    g_bIsHooked[id] = false;
}

public cmd_HookSpeed(id)
{
    client_print(id, print_chat, "Set speed, argument is:");
    return PLUGIN_HANDLED;
}

public cmd_HookOn(id)
{
    if (!is_user_alive(id) || g_bIsHooked[id])
    {
        return PLUGIN_HANDLED;
    }

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
    }

    free_tr2(trace);

    return PLUGIN_HANDLED;
}

public cmd_HookOff(id)
{
    if (!is_user_alive(id))
    {
        return PLUGIN_HANDLED;
    }

    g_bIsHooked[id] = false;

    return PLUGIN_HANDLED;
}

public OnPlayerPreThink(id)
{
    if (!is_user_alive(id)) {
        return FMRES_IGNORED;
    }

    if (!g_bIsHooked[id]) {
        return FMRES_IGNORED;
    }

    new Float:origin[3];
    new Float:direction[3];
    new Float:velocity[3];

    pev(id, pev_origin, origin);

    xs_vec_sub(g_vecHookPoint[id], origin, direction);

    xs_vec_normalize(direction, direction);
    xs_vec_mul_scalar(direction, get_pcvar_float(g_cvHookSpeed), velocity);

    set_pev(id, pev_velocity, velocity);

    return FMRES_IGNORED;
}
