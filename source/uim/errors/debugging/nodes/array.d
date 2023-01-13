/*********************************************************************************************************
	Copyright: © 2015-2023 Ozan Nurettin Süel (Sicherheitsschmiede)                                        
	License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.  
	Authors: Ozan Nurettin Süel (Sicherheitsschmiede)                                                      
**********************************************************************************************************/
module uim.errors.debugs.nodes;

// Dump node for Array values.
class DERRArrayNode : IERRNode {
  private DERRArrayItemNode _items;

  /**
    * Constructor
    *
    * @param array<uim.errors.debugs.DERRArrayItemNode> myItems The items for the array
    */
  this(IERRNode[] someItems = null) {
    _items = [];
    foreach (myItem; someItems) {
      this.add(myItem);
    }
  }

  /**
    * Add an item
    *
    * aNode - The item to add.
    */
  void add(DERRArrayItemNode aNode) {
    _items ~= aNode;
  }

  // Get the contained items
  DERRArrayItemNode getValue() {
      return this.items;
  }

  // Get Item nodes
  IERRNode[]  getChildren() {
    return this.items;
  }
}
