/**
 * Follower maze server
 */

module follower_maze;

import net.server.MultiServerApp;

import fm.EventSourceHandler;
import fm.FollowerMaze;
import fm.UserClientHandler;

/**
 * Constants
 */

enum ADDRESS = "127.0.0.1";
enum PORTS = [9090, 9099];
enum BACKLOG = 10;
enum MAX_CONNS = 60;

/**
 * Application type alias
 */

alias App = MultiServerApp!(EventSourceHandler, UserClientHandler);

/**
 * Main
 */

void main ( )
{
    auto fm = new FollowerMaze();

    EventSourceHandler createEventSourceHandler ( )
    {
        return new EventSourceHandler(fm);
    }

    UserClientHandler createUserClientHandler ( )
    {
        return new UserClientHandler(fm);
    }

    auto config = App.Config(ADDRESS, PORTS, BACKLOG, MAX_CONNS);
    auto app = new App(config, &createEventSourceHandler, &createUserClientHandler);
    app.run();
}
