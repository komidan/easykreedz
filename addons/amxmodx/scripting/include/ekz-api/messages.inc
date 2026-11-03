/**
 * messages.inc
 *
 * Wrappers for CromChat built around certain functionalities.
 * https://github.com/OciXCrom/CromChat
 */
#if defined __EKZ_MESSAGES_INCLUDED__
    #endinput
#endif
#define __EKZ_MESSAGES_INCLUDED__

// You can define these yourself in a plugin to overwrite the default.
#if !defined EKZ_CHAT_TAG
    #define EKZ_CHAT_TAG "^7EKZ ^4> ^1"
#endif
#if !defined EKZ_CONSOLE_TAG
    #define EKZ_CONSOLE_TAG "[EKZ] "
#endif

#if !defined CC_COLORS_TYPE
    #define CC_COLORS_TYPE CC_COLORS_STANDARD
#endif

#include <thirdparty/cromchat>
#include <ekz-core/globals>

/**
 * Currently, only does CC_SetPrefix(), might do more later. Put this inside
 * your `plugin_init()` function to setup messages.
 *
 * @noreturn
 */
stock ekz_chat_init()
{
    CC_SetPrefix(EKZ_CHAT_TAG);
}

/**
 * Sends a message to user's chat using EKZ_CHAT_TAG as a prefix.
 *
 * @param id        User ID
 * @param fmt       Format string
 * @param ...
 *
 * @noreturn
 */
stock ekz_send_chat(id, const fmt[], ...)
{
    new buffer[256];
    vformat(buffer, charsmax(buffer), fmt, 3);

    CC_SendMessage(id, "%s", buffer);
}

/**
 * Sends a chat message to all connected players using EKZ_CHAT_TAG.
 *
 * @param fmt       Format string
 * @param ...       Format arguments
 *
 * @noreturn
 */
stock ekz_send_chat_all(const fmt[], ...)
{
    new buffer[256];
    vformat(buffer, charsmax(buffer), fmt, 2);

    new players[MAXPLAYERS], num;
    get_players(players, num, "ch");

    for (new i = 0; i < num; i++) {
        ekz_send_chat(players[i], "%s", buffer);
    }
}

/**
 * Sends a message to user's console using EKZ_CONSOLE_TAG as a prefix.
 *
 * @param id        User ID
 * @param fmt       Format string
 * @param ...
 *
 * @noreturn
 */
stock ekz_send_console(id, const fmt[], ...)
{
    new buffer[256];
    vformat(buffer, charsmax(buffer), fmt, 3);

    client_print(id, print_console, "%s%s", EKZ_CONSOLE_TAG, buffer);
}

/**
 * Sends a console message to all connected players using EKZ_CONSOLE_TAG.
 *
 * @param fmt       Format string
 * @param ...       Format arguments
 *
 * @noreturn
 */
stock ekz_send_console_all(const fmt[], ...)
{
    new buffer[256];
    vformat(buffer, charsmax(buffer), fmt, 2);

    new players[MAXPLAYERS], num;
    get_players(players, num, "ch");

    for (new i = 0; i < num; i++) {
        ekz_send_console(players[i], "%s", buffer);
    }
}
