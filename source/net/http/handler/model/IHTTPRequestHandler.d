/**
 * Abstract class for a server handler that handles HTTP requests
 *
 * Generates and sends an HTTP response for each request
 */

module net.http.handler.model.IHTTPRequestHandler;

import net.http.Request;
import net.http.Response;
import net.server.handler.model.ISendReceiveHandler;

import std.stdio;

/**
 * HTTP request handler abstract class
 */

abstract class IHTTPRequestHandler : ISendReceiveHandler
{
    /**
     * The HTTP request
     */

    protected HTTPRequest request;

    /**
     * The function to call when data is received
     *
     * Attemps to parse an HTTP request
     *
     * Params:
     *      msg = The data received
     */

    override protected void onReceive ( string msg )
    {
        writefln("Recevied request:\n%s", msg);

        try
        {
            this.request = HTTPRequest(msg);
        }
        catch ( Exception e )
        {
            writefln("Error parsing HTTP request: %s", this.request);
        }
    }

    /**
     * Generate and send the HTTP response
     *
     * Returns:
     *      The response message
     */

    override protected string onSend ( )
    {
        auto response = this.createResponse();

        writefln("Sending response:\n%s", response);

        return response;
    }

    /**
     * Override this, generate the HTTP response
     *
     * Returns:
     *      The response
     */

    abstract protected HTTPResponse createResponse ( );
}
