/**
 * player.inc
 *
 * Many checks using Fakemeta and other functions.
 */

#if defined __EKZ_API_PLAYER_INCLUDED__
    #endinput
#endif
#define __EKZ_API_PLAYER_INCLUDED__

#include <amxmisc>
#include <fakemeta>

#pragma semicolon 1

/**
 * Returns if the player is on the ground or not
 *
 * @param id           Player ID
 *
 * @return bool
 */
stock bool:ekz_player_onground(id)
{
    return (pev(id, pev_flags) & FL_ONGROUND) != 0;
}

/**
 * Returns if the player is ducking
 *
 * @param id           Player ID
 *
 * @return bool
 */
stock bool:ekz_player_is_ducking(id)
{
    return (pev(id, pev_flags) & FL_DUCKING) != 0;
}

/**
 * Returns if the player is in the valid client index range
 *     1 <= id <= MaxClients
 *
 * @param id           Player ID
 *
 * @return bool
 */
stock bool:ekz_player_is_indexed(id)
{
    return 1 <= id <= MaxClients;
}

/**
 * Returns true if the player has access to ADMIN_* flags.
 *  https://amxmodx.org/api/amxconst
 *
 * @param id           Player ID
 * @param flag         Bitflag(s)
 *
 * @return bool
 */
stock bool:ekz_player_has_access(id, flags)
{
    if (!is_dedicated_server() && id == 1)
        return true;

    return access(id, flags) != 0;
}
