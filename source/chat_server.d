/**
 * TCP server
 */

module chat_server;

import net.server.SingleServerApp;
import net.server.handler.UserHandler;

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
    auto config = App.Config(ADDRESS, PORT, BACKLOG, MAX_CONNS);
    auto app = new App(config);
    app.run();
}
