/**
 * Common HTTP definitions
 */

module net.http.Common;

/**
 * HTTP headers type
 */

alias HTTPHeaders = string[string];

/**
 * Supported versions
 */

enum HTTPVersion {
    HTTP_1_0,
    HTTP_1_1
}

enum HTTP_VERSION_STR = [
    HTTPVersion.HTTP_1_0: "HTTP/1.0",
    HTTPVersion.HTTP_1_1: "HTTP/1.1"
];

enum HTTP_STR_VERSION = [
    "HTTP/1.0": HTTPVersion.HTTP_1_0,
    "HTTP/1.1": HTTPVersion.HTTP_1_1
];
