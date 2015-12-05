/**
 * Simple port scanner client
 *
 * Tries to connect to each port from 0 to ushort.max
 * Prints a message for each successful connection
 */

module portscan_client;

import net.client.model.ITcpClientApp;

import std.socket;
import std.stdio;

/**
 * The application
 */

class PortScanApp : ITcpClientApp!true
{
    /**
     * The address to scan
     */

    private string address;

    /**
     * Constructor
     *
     * Params:
     *      address = The address to scan
     */

    this ( string address )
    {
        this.address = address;
    }

    /**
     * The main app logic
     */

    override protected void run ( )
    {
        ushort port = 0;

        while ( port <= ushort.max )
        {
            try
            {
                this.socket.connect(new InternetAddress(this.address, port));
                writefln("Successfully connected to %s:%d", this.address, port);
                this.socket.close();
            }
            catch ( Exception )
            {

            }

            port++;
        }
    }
}

/**
 * Main
 */

void main ( string[] args )
{
    if ( args.length != 2 )
    {
        writefln("Usage: portscan_client [ADDRESS]");
        return;
    }

    auto app = new PortScanApp(args[1]);
    app.main();
}
