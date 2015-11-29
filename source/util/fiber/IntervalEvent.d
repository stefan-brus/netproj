/**
 * A fiber that calls a delegate every n seconds
 */

module util.fiber.IntervalEvent;

import core.thread;

import std.datetime;

/**
 * Interval event class
 */

class IntervalEvent
{
    /**
     * The delegate to call
     */

    private alias EventDg = void delegate ( );

    private EventDg dg;

    /**
     * The interval
     */

    private uint interval;

    /**
     * The fiber
     */

    private Fiber fiber;

    /**
     * The last time the delegate was called
     */

    private SysTime last;

    /**
     * Constructor
     *
     * Params:
     *      dg = The delegate to call
     *      interval = The interval in seconds
     */

    this ( EventDg dg, uint interval )
    {
        this.dg = dg;
        this.interval = interval;
        this.fiber = new Fiber(&this.fiberRun);
    }

    /**
     * Start the event
     */

    void start ( )
    {
        this.fiber.reset();
        this.last = Clock.currTime();
        this.fiber.call();
    }

    /**
     * Resume the event
     */

    void resume ( )
    {
        this.fiber.call();
    }

    /**
     * The fiber routine
     *
     * Calls the delegate if interval seconds has passed
     */

    private void fiberRun ( )
    {
        while ( true )
        {
            auto cur = Clock.currTime();

            if ( cur >= this.last + dur!"seconds"(this.interval) )
            {
                this.last = cur;
                this.dg();
            }

            Fiber.yield();
        }
    }
}
