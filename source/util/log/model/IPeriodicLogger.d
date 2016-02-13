/**
 * Periodic logger interface
 */

module util.log.model.IPeriodicLogger;

import util.log.model.ILogger;

/**
 * Logger interface
 */

interface IPeriodicLogger : ILogger
{
    /**
     * Start the logger
     */

    void start ( );

    /**
     * Resume the logger
     */

    void resume ( );
}
