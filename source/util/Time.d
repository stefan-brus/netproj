/**
 * Time utilities
 */

module util.Time;

import std.datetime;

/**
 * Get the current timestamp as a human-readable string
 */

string curTimeStr ( )
{
    auto cur = Clock.currTime();
    cur.fracSecs = Duration.zero;

    return cur.toSimpleString();
}
