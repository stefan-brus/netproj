/**
 * Set for managing a set of hashed strings
 */

module util.container.HashingSet;

import util.Array;
import util.Hash;

/**
 * The hashing pseudo-set class
 *
 * TODO: Make this an actual set instead of an array wrapper
 */

class HashingSet
{
    /**
     * The internal array of hashes
     */

    ulong[] hashes;

    /**
     * In operator, check if the internal array contains the
     * hash of the given string
     *
     * Params:
     *      str = The string
     *
     * Returns:
     *      True if the hash is present, false otherwise
     */

    bool opIn_r ( string str )
    {
        return this.hashes.contains(fnv1aStr(str));
    }

    /**
     * Put a string into the set
     *
     * Params:
     *      str = The string
     */

    void put ( string str )
    {
        auto hash = fnv1aStr(str);

        if ( !this.hashes.contains(hash) )
        {
            this.hashes ~= hash;
        }
    }
}

unittest
{
    auto set = new HashingSet();

    assert(!("hello" in set));

    set.put("hello");

    assert("hello" in set);
}
