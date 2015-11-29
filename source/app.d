/**
 * TCP server
 */

module app;

import std.algorithm;
import std.socket;
import std.stdio;

/**
 * Constants
 */

enum ADDRESS = "127.0.0.1";
enum PORT = 666;
enum BACKLOG = 10;
enum MAX_CONNS = 60;

/**
 * Main
 */

void main ( )
{
    auto server = new TcpSocket();
    server.blocking = false;
    server.bind(new InternetAddress(ADDRESS, PORT));
    server.listen(BACKLOG);
    writefln("Listening on %s", server.localAddress());

    while ( true )
    {
        auto client = server.accept();

        if ( client.isAlive )
        {
            writefln("Accepted connection from %s", client.remoteAddress());

            char[1024] buf;
            int received = 0;

            while ( received <= 0 )
            {
                received = client.receive(buf);
            }

            auto msg = buf[0 .. received];
            int sent = 0;

            writefln("Received: %s", msg);

            while ( sent < msg.length )
            {
                sent += client.send(msg[sent .. $]);
            }

            client.shutdown(SocketShutdown.BOTH);
            client.close();
        }
    }
}
