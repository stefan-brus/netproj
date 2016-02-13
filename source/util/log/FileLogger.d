/**
 * File logger base class
 */

module util.log.FileLogger;

import util.log.model.ILogger;
import util.Time;

import std.stdio;

/**
 * File logger class
 */

class FileLogger : ILogger
{
    /**
     * The log file
     */

    protected File log_file;

    /**
     * Constructor
     *
     * Params:
     *      path = The path to the log file
     */

    this ( string path )
    {
        this.log_file.open(path, "a");
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
    in
    {
        assert(this.log_file.isOpen);
    }
    body
    {
        this.log_file.writefln("[%s] " ~ str, curTimeStr(), args);
        this.log_file.flush();
    }
}
