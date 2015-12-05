/**
 * Client that sends the message "ping" to 127.0.0.1:666
 *
 * Waits for a response indefinitely
 */

module ping_client;

import net.client.model.ITcpClientApp;

import std.socket;
import std.stdio;

/**
 * Constants
 */

enum ADDRESS = "127.0.0.1";
enum PORT = 666;
enum MESSAGE = "PING";

/**
 * The application
 */

class PingApp : ITcpClientApp!true
{
    /**
     * The main app logic
     */

    override protected void run ( )
    {
        this.socket.connect(new InternetAddress(ADDRESS, PORT));
        assert(this.socket.isAlive);
        writefln("Connected to %s", this.socket.remoteAddress());

        this.socket.send(MESSAGE);
        writefln("%s sent", MESSAGE);

        char[1024] buf;
        int received = 0;

        while ( received <= 0 )
        {
            received = this.socket.receive(buf);
        }

        writefln("Response: %s", buf[0 .. received]);

        writefln("Closing connection");
        this.socket.shutdown(SocketShutdown.BOTH);
        this.socket.close();
    }
}

/**
 * Main
 */

void main ( )
{
    auto app = new PingApp();
    app.main();
}
