/**
 * cvar.inc
 *
 * Makes creating CVARs for plugins easier.
 */

#if defined __EKZ_API_CVAR_INCLUDED__
    #endinput
#endif
#define __EKZ_API_CVAR_INCLUDED__

#include <cvars>

enum _:CvarData {
    CVAR_NAME[32],
    CVAR_DEFAULT[16],
    CVAR_FLAGS,
    CVAR_DESC[64],
    bool:CVAR_HAS_MIN,
    Float:CVAR_MIN,
    bool:CVAR_HAS_MAX,
    Float:CVAR_MAX
};

/**
 * Creates ConVars from a 2D array following the function signature of
 * `create_cvar()` (https://www.amxmodx.org/api/cvars/create_cvar)
 *
 * @param cvars[][CvarData]        2D Array of Cvars
 * @param size                     sizeof(cvars)
 *
 * @return amount of ConVars registered
 */
stock ekz_create_cvars(const cvars[][CvarData], size)
{
    new cvar;
    new registered;

    if (size <= 0) {
        log_amx("No cvars provided. Did you supply the size correctly?");
        return 0;
    }

    for (new i = 0; i < size; i++) {
        if (cvars[i][CVAR_NAME][0] == EOS) {
            log_amx("Invalid Cvar name at index %d.", i);
            continue;
        }

        if (cvars[i][CVAR_DEFAULT][0] == EOS) {
            log_amx("Missing default value for '%s'.", cvars[i][CVAR_NAME]);
            continue;
        }

        cvar = create_cvar(
            cvars[i][CVAR_NAME],
            cvars[i][CVAR_DEFAULT],
            cvars[i][CVAR_FLAGS],
            cvars[i][CVAR_DESC],
            cvars[i][CVAR_HAS_MIN],
            cvars[i][CVAR_MIN],
            cvars[i][CVAR_HAS_MAX],
            cvars[i][CVAR_MAX]
        );

        if (!cvar) {
            log_amx("Failed to register '%s'.", cvars[i][CVAR_NAME]);
            continue;
        }

        registered++;
    }

    return registered;
}
