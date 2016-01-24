/**
 * TCP server
 */

module chat_server;

import chat.UserHandler;

import net.server.SingleServerApp;

import core.thread;

import std.socket;
import std.stdio;

/**
 * Constants
 */

enum ADDRESS = "127.0.0.1";
enum PORT = 666;
enum BACKLOG = 10;
enum MAX_CONNS = 60;

/**
 * Application type alias
 */

alias App = SingleServerApp!UserHandler;

/**
 * Main
 */

void main ( )
{
    UserHandler createHandler ( )
    {
        return new UserHandler();
    }

    auto config = App.Config(ADDRESS, PORT, BACKLOG, MAX_CONNS);
    auto app = new App(config, &createHandler);
    app.run();
}
