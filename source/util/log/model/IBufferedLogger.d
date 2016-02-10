/**
 * Buffered logger abstract class
 *
 * Prefixes messages with the current timestamp
 */

module util.log.model.IBufferedLogger;

import util.log.model.ILogger;
import util.Time;

import std.format;

/**
 * Buffered logger abstract class
 */

abstract class IBufferedLogger : ILogger
{
    /**
     * The log message buffer
     */

    string[] log_buf;

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

    void flush ( )
    {
        while ( this.log_buf.length > 0 )
        {
            this.handle(this.log_buf[0]);

            if ( this.log_buf.length > 1 )
            {
                this.log_buf = this.log_buf[1 .. $];
            }
            else
            {
                this.log_buf.length = 0;
            }
        }
    }

    /**
     * Override this, handle a log message
     *
     * Params:
     *      msg = The log message
     */

    abstract protected void handle ( string msg );
}
