/*********************************************************************************************************
	Copyright: © 2015-2023 Ozan Nurettin Süel (Sicherheitsschmiede)                                        
	License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.  
	Authors: Ozan Nurettin Süel (Sicherheitsschmiede)                                                      
**********************************************************************************************************/
module uim.errors.debugs.nodes;

/**
 * Dump node for objects/class instances.
 */
class ClassNode : IERRNode {
    private string _className;

    private int $id;

    private PropertyNode[] $properties = [];

    /**
     * Constructor
     *
     * @param string myClass The class name
     * @param int $id The reference id of this object in the DumpContext
     */
    this(string aClassName, int $id) {
        _className = aClassName;
        this.id = $id;
    }

    /**
     * Add a property
     *
     * @param uim.errors.debugs.PropertyNode myNode The property to add.
     */
    void addProperty(PropertyNode aNode) {
        _properties ~= aNode;
    }

    /**
     * Get the class name
     */
    string getValue() {
        return _className;
    }

    // Get the reference id
    int getId() {
        return this.id;
    }

    /**
     * Get property nodes
     *
     * @return array<uim.errors.debugs.PropertyNode>
     */
    IERRNode[] getChildren() {
        return this.properties;
    }
}
