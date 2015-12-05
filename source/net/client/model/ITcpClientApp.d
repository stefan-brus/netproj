/**
 * Abstract class for an app that uses a TCP client socket
 */

module net.client.model.ITcpClientApp;

import std.socket;

/**
 * Abstarct TCP client app class
 *
 * Template params:
 *      Blocking = Whether or not the socket should be blocking
 */

abstract class ITcpClientApp ( bool Blocking )
{
    /**
     * The client socket
     */

    protected TcpSocket socket;

    /**
     * Constructor
     */

    this ( )
    {
        this.socket = new TcpSocket();
        this.socket.blocking = Blocking;
    }

    /**
     * The entry point
     */

    void main ( )
    {
        this.run();
    }

    /**
     * Override this, the main app logic
     */

    abstract protected void run ( );
}
