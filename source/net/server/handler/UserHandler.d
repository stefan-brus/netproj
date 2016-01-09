/**
 * Handle a user connection
 */

module net.server.handler.UserHandler;

import net.server.handler.model.ISendReceiveHandler;

import std.socket;
import std.stdio;

/**
 * User handler class
 */

class UserHandler : ISendReceiveHandler
{
    /**
     * The received message
     */

    private string msg;

    /**
     * The user address
     */

    private string address;

    /**
     * onConnect implementation
     */

    override protected void onConnect ( Socket client )
    {
        this.address = client.remoteAddress().toString();
        writefln("Accepted connection from %s", this.address);
    }

    /**
     * onClose implementation
     */

    override protected void onClose ( )
    {
        writefln("Connection closed: %s", this.address);
    }

    /**
     * onReceive implementation
     */

    override protected void onReceive ( string msg )
    {
        writefln("%s received: %s", this.toString(), msg);
        this.msg = msg;
    }

    /**
     * onSend implementation
     */

    override protected string onSend ( )
    {
        writefln("%s response: %s", this.toString(), this.msg);
        return this.msg;
    }

    /**
     * toString implementation
     */

    override public string toString ( )
    {
        return this.address;
    }
}
