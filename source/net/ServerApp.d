/**
 * TCP Server application
 *
 * Starts a fiber that listens indefinitely on a server socket
 * Creates a connection handler from an object pool for each incoming connection
 */

module net.ServerApp;

import net.ConnectionPool;

import core.thread;

import std.socket;
import std.stdio;

/**
 * Server app class
 */

class ServerApp
{
    /**
     * App configuration
     */

    struct Config
    {
        /**
         * The address to listen on
         */

        string address;

        /**
         * The port to listen on
         */

        ushort port;

        /**
         * The connection backlog
         */

        int backlog;

        /**
         * The maximum number of client connections
         */

        uint max_conns;
    }

    private Config config;

    /**
     * The main app fiber
     */

    private Fiber fiber;

    /**
     * The connection pool
     */

    private ConnectionPool pool;

    /**
     * Constructor
     *
     * Params:
     *      config = The configuration
     *      dg = The connection handler delegate
     */

    this ( Config config, ConnectionDg dg )
    {
        this.config = config;
        this.fiber = new Fiber(&this.fiberRun);
        this.pool = new ConnectionPool(dg, this.config.max_conns);
    }

    /**
     * Run the app, handing over control to the main fiber
     */

    void run ( )
    {
        while ( true )
        {
            this.fiber.call();
        }
    }

    /**
     * The main fiber routine
     */

    private void fiberRun ( )
    {
        auto server = new TcpSocket();
        server.blocking = false;
        server.bind(new InternetAddress(this.config.address, this.config.port));
        server.listen(this.config.backlog);
        writefln("Listening on %s", server.localAddress());

        while ( true )
        {
            auto client = server.accept();

            if ( client.isAlive )
            {
                if ( !this.pool.dispatch(client) )
                {
                    // Send without checking for success
                    client.send("Error: Connections full");
                    client.close();
                }
            }
            else
            {
                client.close();
            }

            this.pool.resume();
        }
    }
}
