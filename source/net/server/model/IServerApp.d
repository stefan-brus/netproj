/**
 * Base class for a TCP server application
 */

module net.server.model.IServerApp;

import core.thread;

import util.log.FileLogger;
import util.log.PeriodicConsoleLogger;

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
     * The server file logger
     */

    protected FileLogger file_logger;

    /**
     * The console logger
     */

    protected PeriodicConsoleLogger console_logger;

    /**
     * Constructor
     */

    this ( )
    {
        this.fiber = new Fiber(&this.fiberRun);
        this.file_logger = new FileLogger("log/server.log");
        this.console_logger = new PeriodicConsoleLogger(1, &this.statusMessage);
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

    /**
     * Override this, generate the server status message
     */

    abstract protected string statusMessage ( );
}
