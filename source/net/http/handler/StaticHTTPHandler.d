/**
 * Server handler to serve static content
 */

module net.http.handler.StaticHTTPHandler;

import net.http.handler.model.IHTTPRequestHandler;
import net.http.Common;
import net.http.Request;
import net.http.Response;

import util.File;

import std.conv;
import std.socket;
import std.stdio;

/**
 * Static HTTP request handler class
 */

class StaticHTTPHandler : IHTTPRequestHandler
{
    /**
     * The file to serve when a GET / request comes
     */

    enum DEFAULT_CONTENT = "index.html";

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
     *
     * Throws:
     *      On file errors
     */

    override protected HTTPResponse createResponse ( )
    {
        auto path = this.request.request_uri == "/" ?
            DEFAULT_CONTENT : this.request.request_uri;

        // Strip leading '/' to allow for relative search paths
        if ( path.length == 0 || path[0] == '/' )
        {
            path = path[1 .. $];
        }

        auto file = File(path, "r");
        enforce(file.isOpen, "Unable to open file: " ~ path);

        HTTPResponse response;
        response.http_version = HTTPVersion.HTTP_1_1;

        response.status = 200;
        response.reason = HTTP_STATUS_REASON[200];

        auto contents = fileContents(file);
        response.http_headers["Content-Length"] = to!string(contents.length);
        response.http_headers["Content-Type"] = "text/html; charset=iso-8859-1";
        response.content = contents;

        return response;
    }
}
