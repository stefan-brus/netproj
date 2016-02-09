/**
 * Data structure to manage an HTTP response
 */

module net.http.Response;

import net.http.Common;

import std.array;
import std.conv;
import std.exception;
import std.format;
import std.string;

/**
 * Some reasons for status codes
 */

enum HTTP_STATUS_REASON = [
    200: "OK",
    404: "Not Found"
];

/**
 * HTTP response struct
 */

struct HTTPResponse
{
    /**
     * The HTTP version
     */

    HTTPVersion http_version;

    /**
     * The status code
     */

    uint status;

    /**
     * The reason phrase
     */

    string reason;

    /**
     * The request headers
     */

    HTTPHeaders http_headers;

    /**
     * The message body
     */

    string content;

    /**
     * Serialize the response to a string
     */

    string toString ( )
    {
        string result;

        result ~= HTTP_VERSION_STR[this.http_version];
        result ~= " ";

        result ~= to!string(this.status);
        result ~= " ";

        result ~= this.reason;
        result ~= "\r\n";

        foreach ( k, v; this.http_headers )
        {
            result ~= format("%s: %s", k, v);
            result ~= "\r\n";
        }

        result ~= "\r\n";
        result ~= this.content;

        return result;
    }

    alias toString this;

    /**
     * Parse a response
     *
     * Params:
     *      str = The response string
     *
     * Returns:
     *      A HTTP response struct
     *
     * Throws:
     *      On a malformed HTTP response string
     */

    static HTTPResponse parse ( string str )
    {
        HTTPResponse result;

        auto splitted = str.splitLines();
        enforce(splitted.length > 1, "HTTP response too short: " ~ str);

        // Parse the status line
        auto status_line = splitted[0].split(" ");
        enforce(status_line.length >= 3, "HTTP status line malformed: " ~ str);

        enforce(status_line[0] in HTTP_STR_VERSION, "Invalid HTTP version: " ~ str);
        result.http_version = HTTP_STR_VERSION[status_line[0]];

        try
        {
            result.status = to!uint(status_line[1]);
        }
        catch ( Exception )
        {
            enforce(false, "Invalid HTTP status code " ~ str);
        }

        result.reason = status_line[2 .. $].join(" ");

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
        result.content = splitted[last_header_idx + 1 .. $].join("\r\n").strip();

        return result;
    }

    static alias opCall = parse;
}

unittest
{
    enum TEST_RESPONSE_STR =
`HTTP/1.1 301 Moved Permanently
Date: Sun, 31 Jan 2016 15:12:38 GMT
Server: Apache
Location: http://www.gamefaqs.com/
Vary: Accept-Encoding
Content-Length: 232
Content-Type: text/html; charset=iso-8859-1

<!DOCTYPE HTML PUBLIC "-//IETF//DTD HTML 2.0//EN">
<html><head>
<title>301 Moved Permanently</title>
</head><body>
<h1>Moved Permanently</h1>
<p>The document has moved <a href="http://www.gamefaqs.com/">here</a>.</p>
</body></html>`;

    auto response = HTTPResponse(TEST_RESPONSE_STR);

    assert(response.http_version == HTTPVersion.HTTP_1_1);
    assert(response.status == 301);
    assert(response.reason == "Moved Permanently");

    assert(response.http_headers["Date"] == "Sun, 31 Jan 2016 15:12:38 GMT");
    assert(response.http_headers["Server"] == "Apache");
    assert(response.http_headers["Location"] == "http://www.gamefaqs.com/");
    assert(response.http_headers["Vary"] == "Accept-Encoding");
    assert(response.http_headers["Content-Length"] == "232");
    assert(response.http_headers["Content-Type"] == "text/html; charset=iso-8859-1");

    auto expected_body = `<!DOCTYPE HTML PUBLIC "-//IETF//DTD HTML 2.0//EN">
<html><head>
<title>301 Moved Permanently</title>
</head><body>
<h1>Moved Permanently</h1>
<p>The document has moved <a href="http://www.gamefaqs.com/">here</a>.</p>
</body></html>`.splitLines().join("\r\n").strip();
    assert(response.content == expected_body);
}

/**
 * Helper function to create a simple 200 OK response
*
 * Returns:
 *      The HTTP 200 OK response
 */

HTTPResponse okResponse ( )
{
    return HTTPResponse("HTTP/1.1 200 OK\r\nContent-Length: 0\r\n");
}
