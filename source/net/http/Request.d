/**
 * Data structure to manage an HTTP request
 */

module net.http.Request;

import net.http.Common;

import std.exception;
import std.format;
import std.string;

/**
 * Supported request methods
 */

enum HTTPMethod {
    GET
}

enum HTTP_METHOD_STR = [
    HTTPMethod.GET: "GET"
];

enum HTTP_STR_METHOD = [
    "GET": HTTPMethod.GET
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
     * The request body
     */

    string request_body;

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
        result ~= this.request_body;

        return result;
    }

    alias toString this;

    /**
     * Parse a request
     *
     * Params:
     *      str = The request string
     *
     * Returns:
     *      A HTTP request struct
     *
     * Throws:
     *      On a malformed HTTP request string
     */

    static HTTPRequest parse ( string str )
    {
        HTTPRequest result;

        auto splitted = str.splitLines();
        enforce(splitted.length >= 1, "HTTP request too short: " ~ str);

        // Parse the request line
        auto status_line = splitted[0].split(" ");
        enforce(status_line.length == 3, "HTTP request line malformed: " ~ str);

        enforce(status_line[0] in HTTP_STR_METHOD, "Invalid HTTP method: " ~ str);
        result.http_method = HTTP_STR_METHOD[status_line[0]];

        result.request_uri = status_line[1];

        enforce(status_line[2] in HTTP_STR_VERSION, "Invalid HTTP version: " ~ str);
        result.http_version = HTTP_STR_VERSION[status_line[2]];

        // Parse the headers
        uint last_header_idx;
        foreach ( i, line; splitted )
        {
            auto header = line.split(" ");
            if ( header.length >= 2 && header[0].length >= 2 && header[0][$ - 1] == ':' )
            {
                last_header_idx = i;
                result.http_headers[header[0][0 .. $ - 1]] = header[1 .. $].join(" ");
            }
        }

        // Everything after the last leader line is the body
        result.request_body = splitted[last_header_idx + 1 .. $].join("\r\n").strip();

        return result;
    }

    static alias opCall = parse;
}

unittest
{
    auto request = HTTPRequest("GET / HTTP/1.1\r\n");
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
    return HTTPRequest("GET " ~ uri ~ " HTTP/1.1\r\nHost: " ~ host ~ "\r\n");
}
