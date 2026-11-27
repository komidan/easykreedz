/**
 * misc.inc
 *
 * Contains miscellaneous functions or definitions.
 */

#if defined __EKZ_API_MISC_INCLUDED__
    #endinput
#endif
#define __EKZ_API_MISC_INCLUDED__

#pragma semicolon 1

// Used to make original binds to nothing.
public cmd_Nothing(id)
{
  return PLUGIN_HANDLED;
}
