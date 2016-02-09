/**
 * Abstract class for a handler that waits for data and sends a response
 */

module net.server.handler.model.ISendReceiveHandler;

import net.server.handler.model.IReceiveHandler;

import core.thread;

import std.socket;

/**
 * Send receive handler abstract class
 */

abstract class ISendReceiveHandler : IReceiveHandler
{
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
            long received = Socket.ERROR;
            this.message.length = 0;

            while ( received == Socket.ERROR )
            {
                bool has_received;
                long last_received;

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
}
