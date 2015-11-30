/**
 * Handle a user connection
 */

module net.UserHandler;

import net.model.ISendReceiveHandler;

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
        writefln("Accepted connection from %s", client.remoteAddress());
        this.address = client.remoteAddress().toString();
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
        writefln("%s received: %s", this.address, msg);
        this.msg = msg;
    }

    /**
     * onSend implementation
     */

    override protected string onSend ( )
    {
        writefln("%s response: %s", this.address, this.msg);
        return this.msg;
    }
}
