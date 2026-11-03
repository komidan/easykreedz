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
    #define EKZ_CONSOLE_TAG "[EKZ]"
#endif

#include <ekz-core/globals>

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

    CC_SendMessage(id, "%s%s", CHAT_TAG, buffer);
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

    print_console(id, "%s%s", CONSOLE_TAG, buffer);
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
