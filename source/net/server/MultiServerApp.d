/**
 * Server application that can listen on multiple ports
 *
 * Can use different handler types for each port
 */

module net.server.MultiServerApp;

import net.server.model.IServerApp;
import net.server.ConnectionPool;

import std.conv;
import std.meta;
import std.socket;
import std.stdio;

/**
 * Multi server app class
 *
 * Template params:
 *      Handlers = The connection handler types
 */

class MultiServerApp ( Handlers ... ) : IServerApp
{
    static assert(Handlers.length > 1, "Use SingleServerApp if you only need to handle one port");

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
         * The ports to listen on
         *
         * The corresponding index in Handlers is the handler type
         * that will be used to listen to a given port
         */

        ushort[] ports;

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
     * The connection pools
     */

    alias Pools = WrapPools!(Handlers);

    private Pools pools;

    static template WrapPools ( T ... )
    {
        static if ( T.length == 1 )
        {
            alias WrapPools = ConnectionPool!(T[0]);
        }
        else
        {
            alias WrapPools = AliasSeq!(ConnectionPool!(T[0]), WrapPools!(T[1 .. $]));
        }
    }

    /**
     * Constructor
     *
     * Params:
     *      config = The configuration
     */

    this ( Config config )
    {
        super();
        this.config = config;

        foreach ( ref pool; this.pools )
        {
            pool = new typeof(pool)(this.config.max_conns);
        }
    }

    /**
     * The main fiber routine
     */

    override protected void fiberRun ( )
    {
        TcpSocket[] servers;

        foreach ( i, _; this.pools )
        {
            auto server = new TcpSocket();
            server.blocking = false;
            server.bind(new InternetAddress(this.config.address, this.config.ports[i]));
            server.listen(this.config.backlog);

            servers ~= server;
            writefln("Listening on %s", server.localAddress());
        }

        this.print_status.start();

        while ( true )
        {
            foreach ( i, pool; this.pools )
            {
                auto client = servers[i].accept();

                if ( client.isAlive )
                {
                    if ( !pool.dispatch(client) )
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
                pool.resume();
            }
        }
    }

    /**
     * Print the server status
     */

    override protected void printStatus ( )
    {
        foreach ( i, pool; this.pools )
        {
            writefln("[%d] Connections: %d busy, %d available, %d max", this.config.ports[i], pool.busy, pool.length, this.config.max_conns);
        }
    }
}
