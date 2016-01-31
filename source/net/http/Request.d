/**
 * Data structure to manage an HTTP request
 */

module net.http.Request;

import net.http.Common;

import std.format;

/**
 * Supported request methods
 */

enum HTTPMethod {
    GET
}

enum HTTP_METHOD_STR = [
    HTTPMethod.GET: "GET"
];

/**
 * HTTP request struct
 */

struct HTTPRequest
{
    /**
     * The request method
     */

    HTTPMethod http_method;

    /**
     * The request URI
     */

    string request_uri;

    /**
     * The HTTP version
     */

    HTTPVersion http_version;

    /**
     * The request headers
     */

    HTTPHeaders http_headers;

    /**
     * Serialize the request to a string
     */

    string toString ( )
    {
        string result;

        result ~= HTTP_METHOD_STR[this.http_method];
        result ~= " ";

        result ~= this.request_uri;
        result ~= " ";

        result ~= HTTP_VERSION_STR[this.http_version];
        result ~= "\r\n";

        foreach ( k, v; this.http_headers )
        {
            result ~= format("%s: %s", k, v);
            result ~= "\r\n";
        }

        result ~= "\r\n";

        return result;
    }

    alias toString this;
}

unittest
{
    auto request = HTTPRequest(HTTPMethod.GET, "/", HTTPVersion.HTTP_1_1);
    assert(request == "GET / HTTP/1.1\r\n\r\n");
}

/**
 * Helper function to create a simple get request to a given URI
 *
 * Params:
 *      uri = The URI
 *      host = The host header
 *
 * Returns:
 *      The HTTP GET request struct
 */

HTTPRequest getUri ( string uri, string host )
{
    return HTTPRequest(HTTPMethod.GET, uri, HTTPVersion.HTTP_1_1, ["Host": host]);
}
