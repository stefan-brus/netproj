/**
 * Base class for a TCP server application
 */

module net.server.model.IServerApp;

import core.thread;

import util.log.PeriodicFileLogger;

/**
 * Server app base class
 */

abstract class IServerApp
{
    /**
     * The main server fiber
     */

    protected Fiber fiber;

    /**
     * The server logger
     */

    protected PeriodicFileLogger logger;

    /**
     * Constructor
     */

    this ( )
    {
        this.fiber = new Fiber(&this.fiberRun);

        enum LOGGER_CONFIG = PeriodicFileLogger.Config("log/server.log", 1, true);
        this.logger = new PeriodicFileLogger(LOGGER_CONFIG);
    }

    /**
     * Run the app, handing over control to the main fiber
     */

    void run ( )
    {
        this.fiber.call();
    }

    /**
     * Override this, the main fiber routine
     */

    abstract protected void fiberRun ( );
}
