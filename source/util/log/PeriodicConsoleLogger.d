/**
 * Periodic console logger class
 */

module util.log.PeriodicConsoleLogger;

import util.fiber.IntervalEvent;
import util.log.model.IPeriodicLogger;
import util.Time;

import std.stdio;

/**
 * Periodic console logger class
 */

class PeriodicConsoleLogger : IPeriodicLogger
{
    /**
     * The interval event
     */

    private IntervalEvent interval_event;

    /**
     * The message generator delegate
     */

    alias GenMessageDg = string delegate ( );

    private GenMessageDg dg;

    /**
     * Constructor
     *
     * Params:
     *      interval = The log interval, in seconds
     *      dg = The message generator delegate
     */

    this ( uint interval, GenMessageDg dg )
    {
        this.interval_event = new IntervalEvent(&this.logMessage, interval);
        this.dg = dg;
    }

    /**
     * Start the logger
     */

    void start ( )
    {
        this.interval_event.start();
    }

    /**
     * Resume the logger
     */

    void resume ( )
    {
        this.interval_event.resume();
    }

    /**
     * Log a message
     *
     * Template params:
     *      Args = The format string arguments
     *
     * Params:
     *      str = The format string
     *      args = The format string arguments
     */

    void log ( Args ... ) ( string str, Args args )
    {
        writefln(str, args);
    }

    /**
     * Generate and log a message
     */

    private void logMessage ( )
    {
        this.log("[%s] %s", curTimeStr(), this.dg());
    }
}
