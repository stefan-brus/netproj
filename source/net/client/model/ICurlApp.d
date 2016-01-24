/**
 * Model for an asynchronous curl-based client application
 *
 * Manages a pool of fibers to run requests in
 */

module net.client.model.ICurlApp;

import core.thread;

import std.net.curl;
import std.stdio;

/**
 * Curl application abstract class
 *
 * Template params:
 *      Context = The handler context type
 */

class ICurlApp ( Context )
{
    /**
     * The curl handlers
     *
     * TODO: Use actual object pool
     */

    private CurlFiberHandler!(Context)[] pool;

    /**
     * Run the app
     *
     * Runs the logic function once, then waits for all handlers to finish
     */

    void run ( )
    {
        this.logic();

        uint handlers_busy = 1;

        while ( handlers_busy > 0 )
        {
            handlers_busy = 0;

            foreach ( handler; this.pool )
            {
                if ( handler.busy() )
                {
                    handler.resume();
                    handlers_busy++;
                }
            }
        }
    }

    /**
     * Override this, the main logic to run once
     */

    abstract protected void logic ( );

    /**
     * Dispatch a handler to the given URL
     *
     * The callback is called when all lines have been received
     *
     * Params:
     *      context = The context
     *      url = The url
     *      dg = The callback delegate
     */

    alias DispatchDg = void delegate ( Context, string );

    protected void dispatch ( Context context, string url, DispatchDg dg )
    {
        bool started;

        foreach ( handler; this.pool )
        {
            if ( !handler.busy() )
            {
                handler.start(context, url, dg);
                break;
            }
        }

        if ( !started )
        {
            auto handler = new CurlFiberHandler!Context();
            this.pool ~= handler;
            handler.start(context, url, dg);
        }
    }
}

/**
 * The curl fiber handler class
 *
 * Template params:
 *      Context = The handler context type
 */

class CurlFiberHandler ( Context )
{
    /**
     * The fiber
     */

    private Fiber fiber;

    /**
     * The context
     */

    private Context context;

    /**
     * The URL
     */

    private string url;

    /**
     * The callback delegate
     */

    private ICurlApp!(Context).DispatchDg dg;

    /**
     * Constructor
     */

    this ( )
    {
        this.fiber = new Fiber(&this.fiberRun);
    }

    /**
     * Start the handler
     *
     * Params:
     *      context = The context
     *      url = The url
     *      dg = The callback delegate
     */

    void start ( Context context, string url, ICurlApp!(Context).DispatchDg dg )
    {
        this.context = context;
        this.url = url;
        this.dg = dg;

        this.fiber.reset();
        this.fiber.call();
    }

    /**
     * Resume the handler
     */

    void resume ( )
    in
    {
        assert(this.fiber.state != this.fiber.state.TERM);
    }
    body
    {
        this.fiber.call();
    }

    /**
     * Check if the handler is busy
     */

    bool busy ( )
    {
        return this.fiber.state != this.fiber.state.TERM;
    }

    /**
     * The fiber routine
     *
     * Fires a get request and calls the delegate on the received data
     */

    private void fiberRun ( )
    in
    {
        assert(this.url.length > 0);
        assert(this.dg !is null);
    }
    body
    {
        try
        {
            auto result = cast(string)get(this.url);

            Fiber.yield();

            this.dg(this.context, result);
        }
        catch ( Exception e )
        {
            writefln("Error handling curl request to %s: %s", this.url, e.msg);
        }
    }
}
