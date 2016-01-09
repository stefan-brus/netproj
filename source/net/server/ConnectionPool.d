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
 *      U = The connection handler constructor arguments
 */

class ConnectionPool ( T : IConnectionHandler, U ... )
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
     * The constructor arguments
     */

    private U args;

    /**
     * Constructor
     *
     * Params:
     *      max_conns = The max number of connections
     *      args = The constructor arguments
     */

    this ( size_t max_conns, U args )
    {
        this.max_conns = max_conns;
        this.args = args;
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
            auto handler = new T(this.args);
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
