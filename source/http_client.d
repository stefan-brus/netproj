/**
 * HTTP client application
 *
 * Usage: http_client [URL]
 */

module http_client;

import net.http.ClientHandler;
import net.http.Request;
import net.http.Response;
import std.stdio;

/**
 * The application
 */

class HttpClientApp
{
    /**
     * The URL
     */

    private string url;

    /**
     * Constructor
     *
     * Params:
     *      url = The URL
     */

    this ( string url )
    {
        this.url = url;
    }

    /**
     * The main app logic
     */

    void main ( )
    {
        auto request = getUri("/", this.url);

        auto handler = new HTTPClientHandler();
        handler.handle(this.url, request, &this.printBody);

        while ( handler.busy() )
        {
            handler.resume();
        }
    }

    /**
     * Print the body of an HTTP response
     *
     * Params:
     *      response = The HTTP response
     */

    void printBody ( HTTPResponse response )
    {
        writeln(response.content);
    }
}

/**
 * Main
 */

void main ( string[] args )
{
    if ( args.length != 2 )
    {
        writefln("Usage: http_client [URL]");
        return;
    }

    auto app = new HttpClientApp(args[1]);
    app.main();
}
