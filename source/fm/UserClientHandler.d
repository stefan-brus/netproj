/**
 * Connection handler for the follower maze user client
 */

module fm.UserClientHandler;

import fm.model.IFollowerMazeHandler;
import fm.Event;
import fm.FollowerMaze;

import std.conv;
import std.stdio;
import std.string;

/**
 * User client handler class
 */

class UserClientHandler : IFollowerMazeHandler
{
    /**
     * This user's id
     */

    private ulong id;

    /**
     * Constructor
     *
     * Params:
     *      fm = The follower maze
     */

    this ( FollowerMaze fm )
    {
        super(fm);
    }

    /**
     * Send an event to this user
     *
     * Serializes the event and writes it to the handler's socket
     *
     * Params:
     *      e = The event
     */

    public void sendEvent ( Event e )
    {
        auto serialized = e.toString();

        writefln("[UserClient %d] Sending: %s", this.id, serialized);

        this.send(serialized);
    }

    /**
     * The function to call when data is received
     *
     * Registers the user with the follower maze
     *
     * Params:
     *      msg = The data received
     */

    override protected void onReceive ( string msg )
    {
        writefln("[UserClient] Received: %s", msg);

        // Remove whitespace
        auto stripped = msg.removechars(" \t\r\n");

        this.id = to!ulong(stripped);
        this.fm.registerUser(this.id, this);

        writefln("[UserClient %d] Registered", this.id);
    }

    /**
     * The function to call when the connection is closed
     */

    override protected void onClose ( )
    {
        this.fm.unregisterUser(this.id);
    }
}
