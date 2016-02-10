/**
 * Logger interface
 */

module util.log.model.ILogger;

/**
 * Logger interface
 */

interface ILogger
{
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

    void log ( Args ... ) ( string str, Args args );
}
