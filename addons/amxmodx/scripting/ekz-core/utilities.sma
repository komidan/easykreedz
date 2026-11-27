/**
 * utilities.sma
 *
 * A lot of code for useful utilites that everyone should have access to when
 * running any map.
 */

#include <fun>

#include <ekz-api/messages>

stock PluginInit_Utilities()
{
    register_clcmd("say /god", "cmd_God");
}

public cmd_God(id)
{
    if (!is_user_alive(id))
        return PLUGIN_HANDLED;

    ToggleGod(id);

    return PLUGIN_HANDLED;
}

stock ToggleGod(id)
{
    new bool:enabled = !get_user_godmode(id);
    set_user_godmode(id, enabled);
    ekz_send_chat(id, "Godmode %s", enabled ? "^4Enabled^1" : "^7Disabled^1");
}
