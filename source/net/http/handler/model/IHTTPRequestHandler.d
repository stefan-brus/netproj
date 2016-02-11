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
     * Default error response
     */

    enum DEFAULT_ERROR = HTTPResponse(
```HTTP/1.1 404 Not Found
Content-Length: 12
Content-Type: text/html; charset=iso-8859-1

four oh four```);

    /**
     * The HTTP request
     */

    protected HTTPRequest request;

    /**
     * Whether or not the request was successfully parsed
     */

    private bool parse_success;

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
            this.parse_success = true;
        }
        catch ( Exception e )
        {
            writefln("Error parsing HTTP request: %s", this.request);
            this.parse_success = false;
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
        if ( !this.parse_success )
        {
            return DEFAULT_ERROR;
        }

        HTTPResponse response;

        try
        {
            response = this.createResponse();
        }
        catch ( Exception e )
        {
            writefln("Error creating HTTP response: %s\nThe request:\n%s", e.msg, this.request);
            return DEFAULT_ERROR;
        }

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
