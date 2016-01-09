/**
 * A TCP socket connection handler that runs in a fiber
 */

module net.server.handler.model.IConnectionHandler;

import core.thread;

import std.socket;

/**
 * Connection handler class
 */

abstract class IConnectionHandler
{
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
     */

    this ( )
    {
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
     * Override this, the main logic of the handler
     *
     * Params:
     *      client = The client socket
     */

    abstract protected void logic ( Socket client );

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
        this.logic(this.socket);
    }
}
