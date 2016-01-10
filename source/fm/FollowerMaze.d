/**
 * Follower maze logic
 */

module fm.FollowerMaze;

import fm.Event;
import fm.UserClientHandler;

import std.algorithm;
import std.stdio;

import util.container.TreeSet;
import util.Array;

/**
 * Follower maze class
 */

class FollowerMaze
{
    /**
     * The map of user IDs to user data
     */

    struct UserData
    {
        /**
         * Reference to this user's connection handler
         */

        UserClientHandler handler;

        /**
         * This user's followers
         */

        ulong[] followers;
    }

    alias UserMap = UserData[ulong];

    private UserMap user_map;

    /**
     * The events awaiting processing
     */

    alias WaitingEvents = TreeSet!Event;

    private WaitingEvents waiting;

    /**
     * The current expected event sequence
     */

    private ulong cur_seq;

    /**
     * Constructor
     */

    this ( )
    {
        this.waiting = new WaitingEvents();
        this.cur_seq = 1;
    }

    /**
     * Push an event to the waiting event set
     *
     * Params:
     *      e = The event
     */

    void pushEvent ( Event e )
    {
        this.waiting.insert(e);
    }

    /**
     * Flushes the waiting events, if the current sequence is at the front
     *
     * Returns:
     *      True if an event was flushed, false otherwise
     */

    bool flushWaiting ( )
    {
        if ( this.waiting.front() !is null && this.waiting.front().sequence == this.cur_seq )
        {
            this.handleEvent(*this.waiting.popFront());

            this.cur_seq++;

            return true;
        }

        return false;
    }

    /**
     * Register a new user
     *
     * Overwrites if a user already exists
     *
     * Params:
     *      id = The user id
     *      handler = The user client handler
     */

    void registerUser ( ulong id, UserClientHandler handler )
    {
        this.user_map[id] = UserData(handler);
    }

    /**
     * Unregister a user
     *
     * Params:
     *      id = The user id
     */

    void unregisterUser ( ulong id )
    {
        this.user_map.remove(id);
    }

    /**
     * Handle a given event
     *
     * Silently ignores events for non-registered users
     *
     * Params:
     *      e = The event
     */

    private void handleEvent ( Event e )
    {
        with ( Event.Type ) switch ( e.type )
        {
            // Only the `To User Id` should be notified
            case Follow:
                if ( e.to_user in this.user_map )
                {
                    this.user_map[e.to_user].handler.sendEvent(e);

                    if ( !this.user_map[e.to_user].followers.contains(e.from_user) )
                    {
                        this.user_map[e.to_user].followers ~= e.from_user;
                    }
                }
                break;

            // No clients should be notified
            case Unfollow:
                if ( e.to_user in this.user_map )
                {
                    this.user_map[e.to_user].followers = this.user_map[e.to_user].followers.remove!(a => a == e.from_user);
                }
                break;

            // All connected *user clients* should be notified
            case Broadcast:
                foreach ( _, data; this.user_map )
                {
                    data.handler.sendEvent(e);
                }
                break;

            // Only the `To User Id` should be notified
            case PrivateMsg:
                if ( e.to_user in this.user_map )
                {
                    this.user_map[e.to_user].handler.sendEvent(e);
                }
                break;

            // All current followers of the `From User ID` should be notified
            case StatusUpdate:
                if ( e.from_user in this.user_map )
                {
                    foreach ( id; this.user_map[e.from_user].followers )
                    {
                        if ( id in this.user_map )
                        {
                            this.user_map[id].handler.sendEvent(e);
                        }
                    }
                }
                break;

            default:
                writefln("[FollowerMaze] Unknown event: %s", e.toString());
                break;
        }
    }
}
