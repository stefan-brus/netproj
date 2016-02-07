/**
 * Async web crawler application
 *
 * Usage: web_crawler URL [MAX_HITS]
 */

module web_crawler;

import arsd.dom;

import net.http.handler.ClientHandler;
import net.http.Request;
import net.http.Response;

import util.container.HashingSet;

import core.thread;

import std.conv;
import std.stdio;

/**
 * The web crawler app
 */

class WebCrawlerApp
{
    /**
     * The set of visited URLs
     */

    private HashingSet visited;

    /**
     * The initial URL
     */

    private string url;

    /**
     * The maximum number of hits, 0 for no limit
     */

    private uint max_hits;

    /**
     * The current number of hits
     */

    private uint hits;

    /**
     * The pool of HTTP client handlers
     */

    private HTTPClientHandler[] handlers;

    /**
     * Constructor
     *
     * Params:
     *      url = The initial URL
     *      max_hits = The maximum number of hits, 0 for no limit
     */

    this ( string url, uint max_hits )
    {
        this.url = url;
        this.max_hits = max_hits;
        this.visited = new HashingSet();
    }

    /**
     * The main logic function, start crawling from the given URL
     */

    void main ( )
    {
        this.dispatch(this.url);

        bool handlers_busy = true;

        while ( handlers_busy )
        {
            handlers_busy = false;

            foreach ( handler; this.handlers )
            {
                if ( handler.busy() )
                {
                    handler.resume();
                    handlers_busy = true;
                }
            }
        }
    }

    /**
     * Parse a HTML document and crawl its links
     *
     * Params:
     *      response = The HTTP response
     */

    private void crawlHtml ( HTTPResponse response )
    {
        auto doc = new Document(response.content);

        foreach ( e; doc.getElementsBySelector("a") )
        {
            auto url = e.getAttribute("href");

            if ( url.length == 0 ) break;

            this.handleUrl(url);

            Fiber.yield();
        }
    }

    /**
     * Handle an URL
     *
     * No handler is dispatched if the URL is the same as the current or
     * the root URL, if the URL has already been visited, or if the
     * maximum number of hits has been reached
     *
     * Params:
     *      url = The URL
     */

    private void handleUrl ( string url )
    {
        if ( url in this.visited )
        {
            return;
        }

        if ( this.max_hits == 0 || this.hits < this.max_hits )
        {
            enum HTTP_PREFIX = "http://";
            if ( url.length > HTTP_PREFIX.length && url[0 .. HTTP_PREFIX.length] == HTTP_PREFIX )
            {
                url = url[HTTP_PREFIX.length .. $];
            }

            if ( url.length > 0 && url[$ - 1] == '/' )
            {
                url = url[0 .. $ - 1];
            }

            if ( url.length > 0 && url[0] == '/' )
            {
                url = this.url ~ url;
            }

            this.dispatch(url);
        }
    }

    /**
     * Dispatch a new client handler for the given URL
     *
     * Params:
     *      url = The URL
     */

    private void dispatch ( string url )
    {
        this.hits++;
        this.visited.put(url);

        try
        {
            bool dispatched;

            foreach ( handler; this.handlers )
            {
                if ( !handler.busy() )
                {
                    handler.handle(url, getUri("/", url), &this.crawlHtml);
                }
            }

            if ( !dispatched )
            {
                this.handlers ~= new HTTPClientHandler();
                this.handlers[$ - 1].handle(url, getUri("/", url), &this.crawlHtml);
            }
        }
        catch ( Exception e )
        {
            writefln("Error dispatching: %s", e.msg);
        }
    }
}

/**
 * Main
 */

void main ( string[] args )
{
    if ( args.length < 2 )
    {
        writefln("USAGE: web_crawler URL [MAX_HITS]");
        return;
    }

    auto url = args[1];
    uint max_hits;

    if ( args.length > 2 ) try
    {
        max_hits = to!uint(args[2]);
    }
    catch ( Exception e )
    {
        writefln("USAGE: web_crawler URL [MAX_HITS]");
        return;
    }

    auto app = new WebCrawlerApp(url, max_hits);
    app.main();
}
