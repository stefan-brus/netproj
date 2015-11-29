/**
 * Client that sends the message "ping" to 127.0.0.1:666
 *
 * Waits for a response indefinitely
 */

module client;

import std.socket;
import std.stdio;

/**
 * Constants
 */

enum ADDRESS = "127.0.0.1";
enum PORT = 666;
enum MESSAGE = "PING";

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

    client.send(MESSAGE);
    writefln("%s sent", MESSAGE);

    char[1024] buf;
    int received = 0;

    while ( received <= 0 )
    {
        received = client.receive(buf);
    }

    writefln("Response: %s", buf[0 .. received]);

    client.shutdown(SocketShutdown.BOTH);
    client.close();
}
