/**
 * utilities.inc
 *
 * A lot of code for useful utilites that everyone should have access to when
 * running any map.
 */

#include <fun>

#include <ekz-api/messages>

public cmd_God(id)
{
    if (!is_user_alive(id)) {
        return PLUGIN_HANDLED;
    }

    new bool:enabled = !get_user_godmode(id);
    set_user_godmode(id, enabled);

    ekz_send_chat(id, "God %s", enabled ? "Enabled" : "Disabled");

    return PLUGIN_HANDLED;
}
