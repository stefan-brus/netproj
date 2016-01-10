/**
 * TCP Server application
 *
 * Starts a fiber that listens indefinitely on a server socket
 * Creates a connection handler from an object pool for each incoming connection
 */

module net.server.SingleServerApp;

import net.server.model.IServerApp;
import net.server.ConnectionPool;

import util.fiber.IntervalEvent;

import core.thread;

import std.socket;
import std.stdio;

/**
 * Server app class
 *
 * Template params:
 *      Handler = The connection handler type
 */

class SingleServerApp ( Handler ) : IServerApp
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
     * The connection pool
     */

    private alias Pool = ConnectionPool!Handler;

    private Pool pool;

    /**
     * Constructor
     *
     * Params:
     *      config = The configuration
     *      create_dg = The delegate to create a new connection handler
     */

    this ( Config config, ConnectionPool!(Handler).CreateHandlerDg create_dg )
    {
        super();
        this.config = config;
        this.pool = new Pool(this.config.max_conns, create_dg);
    }

    /**
     * The main fiber routine
     */

    override protected void fiberRun ( )
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

    override protected void printStatus ( )
    {
        writefln("Connections: %d busy, %d available, %d max", this.pool.busy, this.pool.length, this.config.max_conns);
    }
}
