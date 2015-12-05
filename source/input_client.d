/**
 * Client that sends input from stdin to 120.0.0.1:666 in a loop
 *
 * Waits for a responses indefinitely
 */

module input_client;

import net.client.model.ITcpClientApp;

import std.socket;
import std.stdio;
import std.string;

/**
 * Constants
 */

enum ADDRESS = "127.0.0.1";
enum PORT = 666;

/**
 * The application
 */

class InputApp : ITcpClientApp!true
{
    /**
     * The main app logic
     */

    override protected void run ( )
    {
        this.socket.connect(new InternetAddress(ADDRESS, PORT));
        assert(this.socket.isAlive);
        writefln("Connected to %s", this.socket.remoteAddress());

        scope ( exit )
        {
            writefln("Closing connection");
            this.socket.shutdown(SocketShutdown.BOTH);
            this.socket.close();
        }

        string line;
        while ( (line = readln().chomp()) !is null )
        {
            if ( line == "exit" )
            {
                break;
            }

            this.socket.send(line);

            char[1024] buf;
            int received = 0;

            while ( received <= 0 )
            {
                received = this.socket.receive(buf);
            }

            writefln("%s", buf[0 .. received]);
        }
    }
}

/**
 * Main
 */

void main ( )
{
    auto app = new InputApp();
    app.main();
}
