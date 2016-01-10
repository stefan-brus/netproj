/**
 * Array utilities
 */

module util.Array;

import std.algorithm;

/**
 * Check if an array contains a given element
 *
 * Template params:
 *      T = The element type
 *
 * Params:
 *      arr = The array
 *      e = The element to search for
 *
 * Returns:
 *      True if the array contains the element
 */

bool contains ( T ) ( T[] arr, T e )
{
    return arr.find(e).length > 0;
}

unittest
{
    assert(![].contains(1));
    assert([1].contains(1));
    assert([0,1,2,3,4,5].contains(3));
    assert(![0,1,2,3,4,5].contains(6));
}
