/**
 * Curl-based web crawler application
 *
 * Usage: curl_crawler URL [MAX_HITS]
 */

module curl_crawler;

import arsd.dom;

import net.client.model.ICurlApp;

import util.container.HashingSet;

import core.thread;

import std.conv;
import std.stdio;

/**
 * The context for a curl request
 */

struct CurlContext
{
    /**
     * The root URL
     */

    string root_url;

    /**
     * The current URL
     */

    string cur_url;

    /**
     * The depth of this request
     */

    uint depth;
}

/**
 * The web crawler app
 */

class WebCrawlerApp : ICurlApp!CurlContext
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

    override protected void logic ( )
    {
        this.dispatchCurl(CurlContext(this.url, this.url, 0), this.url);
    }

    /**
     * Parse a HTML document and crawl its links
     *
     * Params:
     *      data = The raw HTML
     */

    private void crawlHtml ( CurlContext context, string data )
    {
        auto doc = new Document(data);

        foreach ( e; doc.getElementsBySelector("a") )
        {
            auto url = e.getAttribute("href");

            if ( url.length == 0 ) break;

            if ( url[0] == '/' )
            {
                url = context.root_url ~ url;
            }

            this.handleUrl(context, url);

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
     *      context = The context
     *      url = The URL
     */

    private void handleUrl ( CurlContext context, string url )
    {
        if ( url in this.visited )
        {
            return;
        }

        writefln("[%d] (%s): %s", context.depth, context.cur_url, url);

        if ( this.max_hits == 0 || this.hits < this.max_hits )
        {
            dispatchCurl(context, url);
        }
    }

    /**
     * Dispatch a new CURL request to the given URL
     *
     * Params:
     *      context = The context
     *      url = The URL
     */

    private void dispatchCurl ( CurlContext context, string url )
    {
        this.hits++;
        this.visited.put(url);
        this.dispatch(CurlContext(context.root_url, url, context.depth + 1), url, &this.crawlHtml);
    }
}

/**
 * Main
 */

void main ( string[] args )
{
    if ( args.length < 2 )
    {
        writefln("USAGE: curl_crawler URL [MAX_HITS]");
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
        writefln("USAGE: curl_crawler URL [MAX_HITS]");
        return;
    }

    auto app = new WebCrawlerApp(url, max_hits);
    app.run();
}
