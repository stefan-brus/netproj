/**
 * Manage a "pool" of connection handlers
 */

module net.ConnectionPool;

import net.ConnectionHandler;

import std.socket;

/**
 * Connection delegate convenience alias
 */

alias ConnectionDg = ConnectionHandler.ConnectionDg;

/**
 * Connection pool class
 */

class ConnectionPool
{
    /**
     * The connection handlers
     *
     * TODO: Use actual object pool
     */

    private ConnectionHandler[] pool;

    /**
     * The maximum number of connections
     *
     * Infinite if 0
     */

    private size_t max_conns;

    /**
     * The connection handler delegate
     */

    private ConnectionDg dg;

    /**
     * Constructor
     *
     * Params:
     *      dg = The handler delegate
     *      max_conns = Optional, the max number of connections
     */

    this ( ConnectionDg dg, size_t max_conns = 0 )
    {
        this.dg = dg;
        this.max_conns = max_conns;
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
            }

            handled = true;
        }

        if ( !handled && (this.max_conns == 0 || this.pool.length < this.max_conns) )
        {
            auto handler = new ConnectionHandler(this.dg);
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
}
