/**
 * File utilities
 *
 * WARNING: Due to the errant nature of file I/O, many of these utilities
 * probably throw exceptions, so handle that.
 */

module util.File;

import std.exception;
import std.stdio;

/**
 * Read the entire contents of a file
 *
 * Params:
 *      file = The file
 *
 * Returns:
 *      The contents of the file
 *
 * Throws:
 *      If the file is not open
 */

string fileContents ( File file )
{
    enforce(file.isOpen, "Unable to read file: " ~ file.name);

    string result;

    foreach ( string line; lines(file) )
    {
        result ~= line;
    }

    return result;
}
