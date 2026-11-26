/**
 * hud.inc
 *
 * helpers for drawing simple messages to the hud
 */

#if defined __EKZ_HUD_INCLUDED__
  #endinput
#endif
#define __EKZ_HUD_INCLUDED__

enum _:HUD_Channels {
  HUD_ANY     = -1,
  HUD_REGULAR =  1,
  HUD_WARNING =  4
};

/**
 * Sends a warning HUD message to a player.
 *
 * @param id        Player index (0 = everyone).
 * @param message   Message to display.
 * @param ...       Optional formatting parameters.
 */
stock ekz_hud_warning(id, const message[], any:...)
{
    new buffer[192];
    vformat(buffer, charsmax(buffer), message, 3);

    set_hudmessage(
        255, 64, 64,  // RGB color
        -1.0, 0.25,   // Position (center, upper portion)
        0,            // Effect
        0.0,          // Effect duration
        2.5,          // Hold duration
        0.1,          // Fade-in
        0.1,          // Fade-out
        HUD_WARNING   // HUD channel
    );

    show_hudmessage(id, "%s", buffer);
}

/**
 * Sends a simple HUD message to a player.
 *
 * @param id        Player index (0 = everyone).
 * @param message   Message to display.
 * @param ...       Optional formatting parameters.
 */
stock ekz_hud_message(id, const message[], any:...)
{
    new buffer[192];
    vformat(buffer, charsmax(buffer), message, 3);

    set_hudmessage(
        255, 255, 255,  // RGB color
        -1.0, 0.25,   // Position (center, upper portion)
        0,            // Effect
        0.0,          // Effect duration
        2.5,          // Hold duration
        0.1,          // Fade-in
        0.1,          // Fade-out
        HUD_ANY       // HUD channel (automatic)
    );

    show_hudmessage(id, "%s", buffer);
}
