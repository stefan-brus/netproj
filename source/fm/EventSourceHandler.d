/**
 * Connection handler for the follower maze event source
 */

module fm.EventSourceHandler;

import fm.model.IFollowerMazeHandler;
import fm.Event;
import fm.FollowerMaze;

import std.stdio;
import std.string;

/**
 * Event source handler class
 */

class EventSourceHandler : IFollowerMazeHandler
{
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
     * The function to call when data is received
     *
     * Pushes the event to the follower maze and then attempts to flush
     * the waiting events until the sequence is broken
     *
     * Params:
     *      msg = The data received
     */

    override protected void onReceive ( string msg )
    {
        foreach ( line; msg.splitLines() )
        {
            writefln("[EventSource] Received: %s", line);

            Event e;

            if ( Event.parse(line, e) )
            {
                this.fm.pushEvent(e);
            }
            else
            {
                writefln("[EventSource] WARNING: Unparsable event %s", line);
            }

            size_t flush_count;

            while ( this.fm.flushWaiting() )
            {
                flush_count++;
            }

            writefln("[EventSource] Flushed %d events", flush_count);
        }
    }
}
