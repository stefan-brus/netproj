/**
 * Logger that periodically logs to a file
 */

module util.log.PeriodicFileLogger;

import util.fiber.IntervalEvent;
import util.log.model.IPeriodicLogger;
import util.log.FileLogger;
import util.Time;

import std.format;
import std.stdio;

/**
 * Periodic file logger class
 */

class PeriodicFileLogger : FileLogger, IPeriodicLogger
{
    /**
     * The interval event
     */

    private IntervalEvent interval_event;

    /**
     * The log message buffer
     */

    private string[] log_buf;

    /**
     * Constructor
     *
     * Params:
     *      path = The path to the log file
     *      interval = The log interval, in seconds
     */

    this ( string path, uint interval )
    {
        super(path);
        this.interval_event = new IntervalEvent(&this.flush, interval);
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
        this.log_buf ~= format("[%s] " ~ str, curTimeStr(), args);
    }

    /**
     * Flush the buffer
     *
     * Calls the handler method for each message before discarding it
     */

    private void flush ( )
    {
        while ( this.log_buf.length > 0 )
        {
            this.log_file.writefln(this.log_buf[0]);

            if ( this.log_buf.length > 1 )
            {
                this.log_buf = this.log_buf[1 .. $];
            }
            else
            {
                this.log_buf.length = 0;
            }
        }

        this.log_file.flush();
    }
}
