/**
 * HTTP server that can serve static content
 */

module http_server;

import net.http.handler.StaticHTTPHandler;
import net.server.SingleServerApp;

/**
 * Constants
 */

enum ADDRESS = "127.0.0.1";
enum PORT = 80;
enum BACKLOG = 10;
enum MAX_CONNS = 60;

/**
 * Application type alias
 */

alias App = SingleServerApp!StaticHTTPHandler;

/**
 * Main
 */

void main ( )
{
    StaticHTTPHandler createHandler ( )
    {
        return new StaticHTTPHandler();
    }

    auto config = App.Config(ADDRESS, PORT, BACKLOG, MAX_CONNS);
    auto app = new App(config, &createHandler);
    app.run();
}
