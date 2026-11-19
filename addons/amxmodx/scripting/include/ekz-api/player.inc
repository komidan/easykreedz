/**
 * player.inc
 *
 * Many checks using Fakemeta and other functions.
 */

#if defined __EKZ_PLAYER_INCLUDED__
    #endinput
#endif
#define __EKZ_PLAYER_INCLUDED__

bool:IsPlayerOnGround(id)
{
    return (pev(id, pev_flags) & FL_ONGROUND) != 0;
}
