/**
 * Hash utilities
 */

module util.Hash;

/**
 * Hash a string with FNV-1a
 *
 * Params:
 *      str = The string to hash
 *
 * Returns:
 *      The 64-bit FNV-1a hash
 */

ulong fnv1aStr ( string str )
{
    enum OFFSET = 0xcbf29ce484222325;
    enum PRIME = 0x100000001b3;

    auto result = OFFSET;

    foreach ( c; str )
    {
        result ^= c;
        result *= PRIME;
    }

    return result;
}

unittest
{
    assert(fnv1aStr("") == 0xcbf29ce484222325);
    assert(fnv1aStr("a") == 0xaf63dc4c8601ec8c);
    assert(fnv1aStr("Bite my shiny metal ass") == 0x1d12c5a019a190a2);
}
