/**
 * Server handler to serve static content
 */

module net.http.handler.StaticHTTPHandler;

import net.http.handler.model.IHTTPRequestHandler;
import net.http.Response;

import std.socket;

/**
 * Static HTTP request handler class
 */

class StaticHTTPHandler : IHTTPRequestHandler
{
    /**
     * The function to call when a client connects
     */

    override protected void onConnect ( Socket client )
    {

    }

    /**
     * The function to call when the connection is closed
     */

    override protected void onClose ( )
    {

    }

    /**
     * Generate the HTTP response
     *
     * Returns:
     *      The response
     */

    override protected HTTPResponse createResponse ( )
    {
        return okResponse();
    }
}
