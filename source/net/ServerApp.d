/**
 * TCP Server application
 *
 * Starts a fiber that listens indefinitely on a server socket
 * Creates a connection handler from an object pool for each incoming connection
 */

module net.ServerApp;

import net.ConnectionPool;
import net.UserHandler;

import util.fiber.IntervalEvent;

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

    private alias UserPool = ConnectionPool!UserHandler;

    private UserPool pool;

    /**
     * The status printer interval event
     */

    private IntervalEvent print_status;

    /**
     * Constructor
     *
     * Params:
     *      config = The configuration
     */

    this ( Config config )
    {
        this.config = config;
        this.fiber = new Fiber(&this.fiberRun);
        this.pool = new UserPool(this.config.max_conns);
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
     * The main fiber routine
     */

    private void fiberRun ( )
    {
        auto server = new TcpSocket();
        server.blocking = false;
        server.bind(new InternetAddress(this.config.address, this.config.port));
        server.listen(this.config.backlog);
        writefln("Listening on %s", server.localAddress());

        this.print_status.start();

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

            this.print_status.resume();
            this.pool.resume();
        }
    }

    /**
     * Print the server status
     */

    private void printStatus ( )
    {
        writefln("Connections: %d busy, %d available, %d max", this.pool.busy, this.pool.length, this.config.max_conns);
    }
}
