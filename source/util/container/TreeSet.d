/**
 * Set that provides sorted access to its elements
 */

module util.container.TreeSet;

import util.Array;

/**
 * TreeSet class
 *
 * This is currently a fake implementation using an array and repeated
 * calls to the array sort function
 *
 * TODO: Use an actual tree
 *
 * Template params:
 *      T = The type to store in the set
 */

class TreeSet ( T )
{
    /**
     * The array of elements
     */

    private T[] elements;

    /**
     * Insert an element
     *
     * Params:
     *      val = The value to insert
     */

    void insert ( T val )
    {
        if ( !this.elements.contains(val) )
        {
            this.elements ~= val;
            this.elements.sort;
        }
    }

    /**
     * Peek at the element at the front of the set
     *
     * Returns:
     *      The element at the front of the set
     */

    T* front ( )
    {
        if ( this.elements.length == 0 )
        {
            return null;
        }
        else
        {
            return &this.elements[0];
        }
    }

    /**
     * Pop the element at the front of the set
     *
     * Returns:
     *      The element at the front
     */

    T* popFront ( )
    {
        if ( this.elements.length == 0 ) return null;

        auto result = &this.elements[0];
        this.elements = this.elements[1 .. $];
        return result;
    }
}
