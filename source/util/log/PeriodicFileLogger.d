/**
 * Logger that periodically logs to a file
 */

module util.log.PeriodicFileLogger;

import util.fiber.IntervalEvent;
import util.log.model.IBufferedLogger;

import std.stdio;

/**
 * Periodic file logger class
 */

class PeriodicFileLogger : IBufferedLogger
{
    /**
     * Logger config
     */

    struct Config
    {
        /**
         * The path to the log file
         */

        string path;

        /**
         * The log interval, in seconds
         */

        uint interval;

        /**
         * Whether or not to also print to console
         */

        bool console;
    }

    private Config config;

    /**
     * The interval event
     */

    public IntervalEvent interval_event;

    /**
     * The log file
     */

    private File log_file;

    /**
     * Constructor
     *
     * Params:
     *      config = The logger config
     */

    this ( Config config )
    {
        this.config = config;
        this.interval_event = new IntervalEvent(&this.flush, this.config.interval);
        this.log_file.open(this.config.path, "a");
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
     * Handle a log message
     *
     * Params:
     *      msg = The log message
     */

    override protected void handle ( string msg )
    {
        if ( this.config.console )
        {
            writefln(msg);
        }

        this.log_file.writefln(msg);
        this.log_file.flush();
    }
}
