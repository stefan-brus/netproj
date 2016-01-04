/**
 * TCP server
 */

module app;

import net.server.ServerApp;
import net.server.UserHandler;

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

alias App = ServerApp!UserHandler;

/**
 * Main
 */

void main ( )
{
    auto config = App.Config(ADDRESS, PORT, BACKLOG, MAX_CONNS);
    auto app = new App(config);
    app.run();
}
