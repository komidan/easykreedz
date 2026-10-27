#include <amxmodx>

#include "ekz-core/globals.inc"

#pragma semicolon 1
#pragma ctrlchar '\'

#define PLUGIN_NAME     "EasyKreedz"
#define PLUGIN_VERSION  "0.1.0"
#define PLUGIN_AUTHOR   "komidan"

public plugin_cfg()
{
    return PLUGIN_HANDLED;
}

public plugin_init()
{
    register_plugin(PLUGIN_NAME, PLUGIN_VERSION, PLUGIN_AUTHOR);

    if (is_dedicated_server()) {
        log_amx("%s Running on Dedicated Server", EKZ_TAG);
        // server initialization here.
    }

    return PLUGIN_HANDLED;
}
