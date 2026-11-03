/**
 * time.inc
 *
 * Time helpers
 */
#if define __EKZ_TIME__
    #endinput
#endif
#define __EKZ_TIME__

/**
 * @brief Gets the current date
 *
 * @param output[]     output buffer
 * @param len          len of buffer
 */
stock GetCurrentDate(output[], len)
{
    get_time("%d-%b-%y", output, len);
}

/**
 * @brief Gets the current time
 *
 * @param output[]     output buffer
 * @param len          len of buffer
 */
stock GetCurrentTime(output[], len)
{
    get_time("%H:%M:%S", output, len);
}

/**
 * @brief Gets the current date & time
 *
 * @param output[]     output buffer
 * @param len          len of buffer
 */
stock GetCurrentDateTime(output[], len)
{
    get_time("%d-%b-%y %H:%M:%S", output, len);
}
