/**
 * Base class for a TCP server application
 */

module net.server.model.IServerApp;

import core.thread;

import util.fiber.IntervalEvent;

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
     * The status printer interval event
     */

    protected IntervalEvent print_status;

    /**
     * Constructor
     */

    this ( )
    {
        this.fiber = new Fiber(&this.fiberRun);
        this.print_status = new IntervalEvent(&this.printStatus, 1);
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
     * Override this, print the server status
     */

    abstract protected void printStatus ( );
}
