/*********************************************************************************************************
	Copyright: © 2015-2023 Ozan Nurettin Süel (Sicherheitsschmiede)                                        
	License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.  
	Authors: Ozan Nurettin Süel (Sicherheitsschmiede)                                                      
**********************************************************************************************************/
module uim.cake.errors.debugs.nodes;

// Dump node for Array values.
class ArrayNode : INode {
  private ArrayItemNode _items;

  /**
    * Constructor
    *
    * @param array<uim.cake.errors.debugs.ArrayItemNode> myItems The items for the array
    */
  this(INode[] someItems = null) {
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
  void add(ArrayItemNode aNode) {
    _items ~= aNode;
  }

  // Get the contained items
  ArrayItemNode getValue() {
      return this.items;
  }

  // Get Item nodes
  INode[]  getChildren() {
    return this.items;
  }
}
