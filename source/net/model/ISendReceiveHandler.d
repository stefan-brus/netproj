/**
 * Abstract class for a handler that waits for data and sends a response
 */

module net.model.ISendReceiveHandler;

import net.ConnectionHandler;

import core.thread;

import std.socket;

/**
 * Send receive handler abstract class
 */

abstract class ISendReceiveHandler : ConnectionHandler
{
    /**
     * The buffer to receive data
     */

    enum RECEIVE_BUF_LEN = 1024 * 1024;

    private char[RECEIVE_BUF_LEN] receive_buf;

    /**
     * Constructor
     */

    this ( )
    {
        super(&this.receiveSendLoop);
    }

    /**
     * Override this, the function to call when a client connects
     */

    abstract protected void onConnect ( Socket client );

    /**
     * Override this, the function to call when the connection is closed
     */

    abstract protected void onClose ( );

    /**
     * Override this, the function to call when data is received
     *
     * Params:
     *      msg = The data received
     */

    abstract protected void onReceive ( string msg );

    /**
     * Override this, the function to call to generate the response
     *
     * Returns:
     *      The response message
     */

    abstract protected string onSend ( );

    /**
     * The receive send loop connection handler delegate
     *
     * Naively assumes that the send will work in one call
     *
     * Params:
     *      client = The client socket
     */

    private void receiveSendLoop ( Socket client )
    {
        this.onConnect(client);

        while ( true )
        {
            int received = Socket.ERROR;

            while ( received == Socket.ERROR )
            {
                received = client.receive(this.receive_buf);
                Fiber.yield();
            }

            if ( received == 0 )
            {
                this.onClose();
                break;
            }

            this.onReceive(cast(string)this.receive_buf[0 .. received]);

            client.send(this.onSend());
        }

        client.shutdown(SocketShutdown.BOTH);
        client.close();
    }
}