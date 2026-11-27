/**
 * player.inc
 *
 * Many checks using Fakemeta and other functions.
 */

#if defined __EKZ_API_PLAYER_INCLUDED__
    #endinput
#endif
#define __EKZ_API_PLAYER_INCLUDED__

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
