/**
 * TCP server
 */

module app;

import net.ServerApp;

import core.thread;

import std.socket;
import std.stdio;

/**
 * Constants
 */

enum ADDRESS = "127.0.0.1";
enum PORT = 666;
enum BACKLOG = 10;
enum MAX_CONNS = 60;

class Handler
{
    void handle ( Socket socket )
    {
        writefln("Accepted connection from %s", socket.remoteAddress());

        char[1024] buf;
        int received = 0;

        while ( received <= 0 )
        {
            received = socket.receive(buf);
            Fiber.yield();
        }

        auto msg = buf[0 .. received];

        writefln("Received: %s", msg);

        socket.send(msg);

        socket.shutdown(SocketShutdown.BOTH);
        socket.close();
    }
}

/**
 * Main
 */

void main ( )
{
    auto config = ServerApp.Config(ADDRESS, PORT, BACKLOG, MAX_CONNS);
    auto handler = new Handler();
    auto app = new ServerApp(config, &handler.handle);
    app.run();
}
