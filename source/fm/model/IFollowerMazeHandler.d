/**
 * Base class for the follower maze connection handlers
 */

module fm.model.IFollowerMazeHandler;

import fm.FollowerMaze;

import net.server.handler.model.IReceiveHandler;

import std.socket;

/**
 * Follower maze handler base class
 */

abstract class IFollowerMazeHandler : IReceiveHandler
{
    /**
     * Follower maze reference
     */

    protected FollowerMaze fm;

    /**
     * Constructor
     *
     * Params:
     *      fm = The follower maze
     */

    this ( FollowerMaze fm )
    {
        this.fm = fm;
    }

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
}
