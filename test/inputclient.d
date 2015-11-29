/**
 * Client that sends input from stdin to 120.0.0.1:666 in a loop
 *
 * Waits for a responses indefinitely
 */

module client;

import std.socket;
import std.stdio;

/**
 * Constants
 */

enum ADDRESS = "127.0.0.1";
enum PORT = 666;

/**
 * Main
 */

void main ( )
{
    auto client = new TcpSocket();
    client.blocking = true;
    client.connect(new InternetAddress(ADDRESS, PORT));
    assert(client.isAlive);
    writefln("Connected to %s", client.remoteAddress());

    scope ( exit )
    {
        writefln("Closing connection");
        client.shutdown(SocketShutdown.BOTH);
        client.close();
    }

    string line;
    while ( (line = readln()) !is null )
    {
        client.send(line);

        char[1024] buf;
        int received = 0;

        while ( received <= 0 )
        {
            received = client.receive(buf);
        }

        writefln("%s", buf[0 .. received]);
    }
}
