/**
 * TCP server
 */

module app;

import net.server.ServerApp;

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
 * Main
 */

void main ( )
{
    auto config = ServerApp.Config(ADDRESS, PORT, BACKLOG, MAX_CONNS);
    auto app = new ServerApp(config);
    app.run();
}
