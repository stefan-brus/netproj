/**
 * Abstract class for a handler that waits for data and sends a response
 */

module net.server.model.ISendReceiveHandler;

import net.server.model.IConnectionHandler;

import core.thread;

import std.socket;

/**
 * Send receive handler abstract class
 */

abstract class ISendReceiveHandler : IConnectionHandler
{
    /**
     * The buffer to receive data
     */

    enum RECEIVE_BUF_LEN = 1024;

    private char[RECEIVE_BUF_LEN] receive_buf;

    private string message;

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
     * The receive send loop main logic method
     *
     * Naively assumes that the send will work in one call
     *
     * Params:
     *      client = The client socket
     */

    override protected void logic ( Socket client )
    {
        this.onConnect(client);

        while ( true )
        {
            int received = Socket.ERROR;
            this.message.length = 0;

            while ( received == Socket.ERROR )
            {
                bool has_received;
                int last_received;

                while ( (last_received = this.receiveAndBuffer(client)) != Socket.ERROR )
                {
                    has_received = true;

                    if ( last_received == 0 )
                    {
                        break;
                    }
                }

                if ( has_received )
                {
                    received = last_received;
                    break;
                }

                Fiber.yield();
            }

            if ( received == 0 )
            {
                this.onClose();
                break;
            }

            this.onReceive(this.message);

            client.send(this.onSend());
        }

        client.shutdown(SocketShutdown.BOTH);
        client.close();
    }

    /**
     * Helper function to receive and buffer from a given socket
     *
     * Appends the received data to the message buffer
     *
     * Params:
     *      client = The client socket
     *
     * Returns:
     *      The number of received bytes
     */

    private int receiveAndBuffer ( Socket client )
    {
        auto received = client.receive(this.receive_buf);

        if ( received != Socket.ERROR )
        {
            this.message ~= cast(string)this.receive_buf[0 ..  received];
        }

        return received;
    }
}
