/**
 * message.inc
 *
 * An API for sending messages using the global EKZ tag easily.
 *
 * Uses CromChat by OciXCrom: https://github.com/OciXCrom/CromChat
 */
#include <ekz-globals>
#include <cromchat.inc>

stock ekz_msg(id, const fmt[], any:...)
{
    new buffer[256];

    if (numargs() > 2) {
        vformat(buffer, charsmax(buffer), fmt, 3);
    } else {
        copy(buffer, charsmax(buffer), fmt);
    }

    CC_Message(id, "%s%s", EKZ_CHAT_TAG, buffer);
}
