/**
 * Manage a "pool" of connection handlers
 */

module net.server.ConnectionPool;

import net.server.handler.model.IConnectionHandler;

import std.socket;

/**
 * Connection pool class
 *
 * Template params:
 *      T = The connection handler type
 */

class ConnectionPool ( T : IConnectionHandler )
{
    /**
     * The connection handlers
     *
     * TODO: Use actual object pool
     */

    private T[] pool;

    /**
     * The maximum number of connections
     *
     * Infinite if 0
     */

    private size_t max_conns;

    /**
     * The delegate to create a new handler
     */

    alias CreateHandlerDg = T delegate ( );

    private CreateHandlerDg create_dg;

    /**
     * Constructor
     *
     * Params:
     *      max_conns = The max number of connections
     *      create_dg = The create handler delegate
     */

    this ( size_t max_conns, CreateHandlerDg create_dg )
    {
        this.max_conns = max_conns;
        this.create_dg = create_dg;
    }

    /**
     * Dispatch the first non-busy handler with the given socket connection
     * Create a new handler if all were busy
     *
     * Params:
     *      socket = The socket
     *
     * Returns:
     *      True if a handler was available
     */

    bool dispatch ( Socket socket )
    {
        bool handled;

        foreach ( handler; this.pool )
        {
            if ( !handler.busy() )
            {
                handler.handle(socket);
                handled = true;
                break;
            }
        }

        if ( !handled && (this.max_conns == 0 || this.pool.length < this.max_conns) )
        {
            auto handler = this.create_dg();
            this.pool ~= handler;
            handler.handle(socket);
            handled = true;
        }

        return handled;
    }

    /**
     * Resume the busy handlers
     */

    void resume ( )
    {
        foreach ( handler; this.pool )
        {
            if ( handler.busy() )
            {
                handler.resume();
            }
        }
    }

    /**
     * Get the number of busy connections
     *
     * Returns:
     *      The number of busy connections
     */

    uint busy ( )
    {
        uint result;

        foreach ( handler; this.pool )
        {
            if ( handler.busy() )
            {
                result++;
            }
        }

        return result;
    }

    /**
     * Get the number of available connections
     *
     * Returns:
     *      The number connections in the pool
     */

    size_t length ( )
    {
        return this.pool.length;
    }
}
