/*********************************************************************************************************
	Copyright: © 2015-2023 Ozan Nurettin Süel (Sicherheitsschmiede)                                        
	License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.  
	Authors: Ozan Nurettin Süel (Sicherheitsschmiede)                                                      
**********************************************************************************************************/
module uim.errors.debugs.nodes;

@safe:
import uim.errors;

/**
 * Dump node for class references.
 *
 * To prevent cyclic references from being output multiple times
 * a reference node can be used after an object has been seen the
 * first time.
 */
class ReferenceNode : IERRNode {
    private string myClass;

    /**
     * @var int
     */
    private $id;

    /**
     * Constructor
     *
     * @param string myClass The class name
     * @param int $id The id of the referenced class.
     */
    this(string myClass, int $id) {
        this.class = myClass;
        this.id = $id;
    }

    /**
     * Get the class name/value
     */
    string getValue() {
        return this.class;
    }

    /**
     * Get the reference id for this node.
     */
    int getId() {
        return this.id;
    }


    IERRNode[] getChildren() {
        return [];
    }
}
