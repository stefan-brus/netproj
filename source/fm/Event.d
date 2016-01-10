/**
 * Data representing a follower maze event
 */

module fm.Event;

import std.array;
import std.conv;
import std.string;

/**
 * Event struct
 */

struct Event
{
    /**
     * The sequence
     */

    ulong sequence;

    /**
     * The event type
     */

    enum Type
    {
        Follow,
        Unfollow,
        Broadcast,
        PrivateMsg,
        StatusUpdate
    }

    Type type;

    enum Type[char] TYPE_CHR_MAP = [
        'F': Type.Follow,
        'U': Type.Unfollow,
        'B': Type.Broadcast,
        'P': Type.PrivateMsg,
        'S': Type.StatusUpdate
    ];

    enum char[Type] CHR_TYPE_MAP = [
        Type.Follow: 'F',
        Type.Unfollow: 'U',
        Type.Broadcast: 'B',
        Type.PrivateMsg: 'P',
        Type.StatusUpdate: 'S'
    ];

    /**
     * The from user id
     */

    ulong from_user;

    /**
     * The to user id
     */

    ulong to_user;

    /**
     * Serialize this event to a string
     *
     * Returns:
     *      This event in string format
     */

    string toString ( )
    {
        string result;

        result ~= to!string(this.sequence);
        result ~= "|";

        result ~= CHR_TYPE_MAP[this.type];
        if ( this.type != Type.Broadcast ) result ~= "|";

        with ( Type ) switch ( this.type )
        {
            case Follow:
                goto case;
            case Unfollow:
                goto case;
            case PrivateMsg:
                result ~= to!string(this.from_user);
                result ~= "|";
                result ~= to!string(this.to_user);
                break;

            case StatusUpdate:
                result ~= to!string(this.from_user);
                break;

            default:
                break;
        }

        result ~= "\r\n";

        return result;
    }

    /**
     * Comparison operator
     *
     * Params:
     *      other = The other event
     *
     * Returns:
     *      Comparison result
     */

    int opCmp ( ref const Event other ) const
    {
        return this.sequence < other.sequence ? -1 :
            this.sequence > other.sequence ? 1 :
            0;
    }

    /**
     * Parse an event from a string
     *
     * Params:
     *      str = The event string
     *      event = The event to write to
     *
     * Returns:
     *      True on successful parse, false otherwise
     */

    static bool parse ( string str, out Event event )
    {
        // Reset event
        event = Event.init;

        // Remove whitespace
        auto stripped = str.removechars(" \t\r\n");

        // Split on | and parse
        foreach ( i, part; stripped.split("|") )
        {
            enum Indices
            {
                IdxSeq = 0,
                IdxType = 1,
                IdxFrom = 2,
                IdxTo = 3
            }

            with ( Indices ) switch ( i )
            {
                case IdxSeq:
                    event.sequence = to!ulong(part);
                    break;

                case IdxType:
                    if ( part.length > 1 || part[0] !in TYPE_CHR_MAP ) return false;
                    event.type = TYPE_CHR_MAP[part[0]];
                    break;

                case IdxFrom:
                    event.from_user = to!ulong(part);
                    break;

                case IdxTo:
                    event.to_user = to!ulong(part);
                    break;

                default:
                    return false;
            }
        }

        return true;
    }
}

unittest
{
    Event e;

    assert(Event.parse("666|F|60|50\r\n", e));
    assert(e.sequence == 666);
    assert(e.type == Event.Type.Follow);
    assert(e.from_user == 60);
    assert(e.to_user == 50);
    assert(e.toString() == "666|F|60|50\r\n");

    assert(Event.parse("1|U|12|9\r\n", e));
    assert(e.sequence == 1);
    assert(e.type == Event.Type.Unfollow);
    assert(e.from_user == 12);
    assert(e.to_user == 9);
    assert(e.toString() == "1|U|12|9\r\n");

    assert(Event.parse("542532|B\r\n", e));
    assert(e.sequence == 542532);
    assert(e.type == Event.Type.Broadcast);
    assert(e.from_user == 0);
    assert(e.to_user == 0);
    assert(e.toString() == "542532|B\r\n");

    assert(Event.parse("43|P|32|56\r\n", e));
    assert(e.sequence == 43);
    assert(e.type == Event.Type.PrivateMsg);
    assert(e.from_user == 32);
    assert(e.to_user == 56);
    assert(e.toString() == "43|P|32|56\r\n");

    assert(Event.parse("634|S|32\r\n", e));
    assert(e.sequence == 634);
    assert(e.type == Event.Type.StatusUpdate);
    assert(e.from_user == 32);
    assert(e.to_user == 0);
    assert(e.toString() == "634|S|32\r\n");
}
