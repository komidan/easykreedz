/**
 * time.inc
 *
 * Time helpers
 */

#if defined __EKZ_API_TIME_INCLUDED__
    #endinput
#endif
#define __EKZ_API_TIME_INCLUDED__

#include <amxmodx>
#include <float>
#include <string>

/**
 * Gets the current date
 *
 * @param output[]     output buffer
 * @param len          len of buffer
 * @noreturn
 */
stock ekz_get_current_date(const output[], len)
{
    get_time("%d-%b-%y", output, len);
}

/**
 * Gets the current time
 *
 * @param output[]     output buffer
 * @param len          len of buffer
 * @noreturn
 */
stock ekz_get_current_time(const output[], len)
{
    get_time("%H:%M:%S", output, len);
}

/**
 * Gets the current date & time
 *
 * @param output[]     output buffer
 * @param len          len of buffer
 * @noreturn
 */
stock ekz_get_current_datetime(const output[], len)
{
    get_time("%d-%b-%y %H:%M:%S", output, len);
}

/**
 * Formats a supplied time as HH:MM:SS:sss
 *
 * @param time         time to be formatted
 * @param output[]     output buffer
 * @param len          len of buffer
 * @noreturn
 */
stock ekz_format_gametime(Float:time, output[], len)
{
    new t = floatround(time * 1000.0);

    new hours = t / 3600000;
    new minutes = (t / 60000) % 60;
    new seconds = (t / 1000) % 60;
    new milliseconds = t % 1000;

    formatex(output, len, "%02d:%02d:%02d:%03d",
        hours, minutes, seconds, milliseconds
    );
}
