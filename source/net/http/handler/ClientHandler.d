/**
 * Asynchronous HTTP client handler
 *
 * Sends a request and calls a callback when a response is received
 */

module net.http.handler.ClientHandler;

import net.http.Request;
import net.http.Response;

import core.thread;

import std.socket;

/**
 * HTTP client handler class
 */

class HTTPClientHandler
{
    /**
     * The fiber
     */

    private Fiber fiber;

    /**
     * The socket
     */

    private Socket socket;

    /**
     * The request
     */

    private HTTPRequest request;

    /**
     * The response delegate
     */

    alias ResponseDg = void delegate ( HTTPResponse );

    private ResponseDg dg;

    /**
     * Constructor
     */

    this ( )
    {
        this.fiber = new Fiber(&this.fiberRun);
        this.socket = new TcpSocket();
        this.socket.blocking = false;
    }

    /**
     * Handle a request
     *
     * Params:
     *      url = The request URL
     *      request = The HTTP request
     *      dg = The response delegate
     */

    void handle ( string url, HTTPRequest request, ResponseDg dg )
    {
        enum DEFAULT_PORT = 80;
        this.socket.connect(new InternetAddress(url, DEFAULT_PORT));

        this.request = request;
        this.dg = dg;

        this.fiber.reset();
        this.fiber.call();
    }

    /**
     * Check if the handler is busy
     */

    bool busy ( )
    {
        return this.socket.isAlive || this.fiber.state != this.fiber.state.TERM;
    }

    /**
     * Resume the handler
     */

    void resume ( )
    in
    {
        assert(this.fiber.state != this.fiber.state.TERM);
    }
    body
    {
        this.fiber.call();
    }

    /**
     * The fiber routine
     */

    private void fiberRun ( )
    in
    {
        assert(this.socket.isAlive);
        assert(this.request != HTTPRequest.init);
        assert(this.dg !is null);
    }
    body
    {
        scope ( exit )
        {
            this.socket.shutdown(SocketShutdown.BOTH);
            this.socket.close();
        }

        int sent_total;

        // Send until the whole request has been sent
        while ( sent_total < this.request.length )
        {
            auto sent = this.socket.send(this.request[sent_total .. $]);

            if ( sent > 0 )
            {
                sent_total += sent;
            }

            Fiber.yield();
        }

        string response_buf;
        char[1024] buf;
        int received;
        int attempts;
        bool has_received;

        // Receive until the max number of attempt cycles has been tried
        // This is a terrible solution
        // TODO: Come up with proper solution
        enum MAX_ATTEMPT_CYCLES = 1_000_000;
        while ( !has_received || received > 0 || attempts < MAX_ATTEMPT_CYCLES )
        {
            received = this.socket.receive(buf);

            if ( received > 0 )
            {
                has_received = true;
                attempts = 0;
                assert(received <= buf.length);
                response_buf ~= buf[0 .. received];
            }
            else if ( has_received )
            {
                attempts++;
            }

            Fiber.yield();
        }

        this.dg(HTTPResponse(response_buf));
    }
}
