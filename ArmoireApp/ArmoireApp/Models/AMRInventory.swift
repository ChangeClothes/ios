//
//  File.swift
//  ArmoireApp
//
//  Created by Mathew Kellogg on 11/13/15.
//  Copyright © 2015 Armoire. All rights reserved.
//

import Foundation

class AMRInventory {
  
  var categories: [AMRInventoryCategory] = []
  
  static func get_inventory() -> AMRInventory {
   
    let inventory = AMRInventory()
    
    var id = 0
    
    for store in ["Nordstroms", "Macys", "Forever 21"]{
      let aStore = AMRInventoryCategory(name: store)
      for cat1 in ["Mens", "Womens", "Childrens"]{
        let aCat1 = AMRInventoryCategory(name: cat1)
        aCat1.subcategories = []
        for cat2 in ["Tops", "Bottoms", "Shoes", "Accessories"]{
          let aCat2 = AMRInventoryCategory(name: cat1)
          aCat2.items = []
          for item in ["Item1", "Item2", "Item3", "Item4", "Item5", "Item6", "Item7"] {
            let item = AMRInventoryItem(name: item, imageUrl: "http://i.imgur.com/a4ZUCPB.jpg", id: String(id), price:7.77)
            id += 1
            aCat2.items!.append(item)
          }
          aCat1.subcategories!.append(aCat2)
        }
        aStore.subcategories!.append(aCat1)
      }
      inventory.categories.append(aStore)
    }
    return inventory
  }
  
}

class AMRInventoryCategory {
  var name: String?
  var items: [AMRInventoryItem]?
  var subcategories: [AMRInventoryCategory]?
  init(name:String?){
    self.name = name
  }
}

class AMRInventoryItem {
  var name: String?
  var imageUrl: String?
  var id: String?
  var price: Float?
  
  init(name:String?, imageUrl: String?, id: String?, price: Float?) {
    self.name = name
    self.imageUrl = imageUrl
    self.id = id
    self.price = price
  }
}