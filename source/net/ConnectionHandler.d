/**
 * A TCP socket connection handler that runs in a fiber
 */

module net.ConnectionHandler;

import core.thread;

import std.socket;

/**
 * Connection delegate convenience alias
 */

alias ConnectionDg = ConnectionHandler.ConnectionDg;

/**
 * Connection handler class
 */

class ConnectionHandler
{
    /**
     * The delegate to run in the fiber
     */

    alias ConnectionDg = void delegate ( Socket );

    private ConnectionDg dg;

    /**
     * The fiber
     */

    protected Fiber fiber;

    /**
     * The socket
     */

    protected Socket socket;

    /**
     * Constructor
     *
     * Params:
     *      dg = The handler delegate
     */

    this ( ConnectionDg dg )
    {
        this.dg = dg;
        this.fiber = new Fiber(&this.fiberRun);
    }

    /**
     * Handle a connection
     *
     * Params:
     *      socket = The socket
     */

    void handle ( Socket socket )
    {
        this.socket = socket;
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
     * Write to the handler's socket
     *
     * Naively assumes that the message can be sent with one send call
     *
     * Params:
     *      msg = The message to write
     */

    void send ( string msg )
    {
        this.socket.send(msg);
    }

    /**
     * Check if the handler is busy
     */

    bool busy ( )
    {
        return this.socket.isAlive || this.fiber.state != this.fiber.state.TERM;
    }

    /**
     * The fiber routine
     *
     * Calls the handler delegate with the current socket
     */

    private void fiberRun ( )
    in
    {
        assert(this.socket !is null);
    }
    body
    {
        this.dg(this.socket);
    }
}
