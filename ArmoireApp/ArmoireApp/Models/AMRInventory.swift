//
//  File.swift
//  ArmoireApp
//
//  Created by Mathew Kellogg on 11/13/15.
//  Copyright © 2015 Armoire. All rights reserved.
//

import Foundation

class AMRInventory {
  
  static var sharedInstance: AMRInventory?
  
  var categories: [AMRInventoryCategory] = []
  
  static func get_inventory(completion: (inventory: AMRInventory)->()) {
   
    let inventory = AMRInventory()
    
    let nordstromData: [String:[String:[String:String]]] = ["Men": ["UNDERWEAR": ["Boxer Briefs": "b60140071", "Trunks": "b60140523", "Briefs": "b60140073", "Jock Straps & Thongs": "b60140074", "Boxers": "b60140072"], "Shoes": ["Dress Shoes": "b60144997", "Athletic": "b2380781", "Oxfords": "b60129352", "Sneakers": "b2380781", "Boots": "b2376165", "Sandals & Flip-Flops": "b2376180", "Boat Shoes": "b60138622", "Loafers & Slip-Ons": "b60129351", "Slippers": "b6014061"], "SHORTS": ["Athletic": "b60159430", "Cargo": "b60179519", "Flat Front": "b60179521", "Hybrid Shorts": "b60179527"], "COATS & JACKETS": ["Peacoats": "b60137678", "Quilted Jackets & Puffer Coats": "b60172243", "Vests": "b60137681", "Leather Jackets": "b60137673", "Denim Jackets": "b60183853", "Cashmere Coats": "b60137676", "Fleece Jackets": "b60156952", "Trench Coats & Overcoats": "b60154584", "Insulated Jackets & Performance Jackets": "b60137679", "Lightweight & Shirt Jackets": "b60137675", "Military Jackets & Utility Jackets": "b60154379", "Ski & Snowboard Jackets": "b60183194", "Down Coats & Jackets": "b60156950", "Bomber Jackets & Varsity Jackets": "b60182435", "Parkas": "b60182438"], "JEANS": ["Straight Leg": "b60138097", "Slim Jeans": "b60138099", "Skinny Jeans": "b60138100", "Bootcut": "b60138098", "Selvedge & Raw Denim": "b60159941", "Relaxed Fit": "b60138095"], "SWIMWEAR": ["Swim Trunks": "b60165285", "Swim Briefs": "b60165279", "Board Shorts": "b60165294"], "SOCKS": ["Dress Socks": "b60140081", "Casual Socks": "b60140083", "Sport Socks": "b60140082", "No-Show Socks": "b60140076"], "SUITS": ["Blazers & Sport Coats": "b60131084", "Tuxedos": "b60134975", "Slim Fit Suits": "b60151067", "Suit Separates": "b60150610", "Suit Vests": "b60142676"], "SHIRTS": ["Dress Shirts": "b60137266", "Tank Tops": "b60140877", "Polos": "b60137709", "Slim Fit Shirts": "b60137354", "V-Neck T-Shirts": "b60140868", "Henleys": "b60140876", "Casual Button-Down Shirts": "b60137692", "Graphic Tees": "b60137699", "Flannel Shirts": "b60184196", "Hawaiian Shirts": "b60181006", "Linen Shirts": "b60162578", "T-Shirts": "b60134125", "No-Iron Shirts": "b60156934"], "WORKOUT CLOTHES": ["Workout Shorts": "b60159430", "Workout Underwear": "b60159432", "Running Pants": "b60159429", "Mens Cycling Clothing": "b60186159", "Workout Shirts": "b60159427"], "SWEATERS": ["Fleece": "b60153721", "Hoodies": "b60153723", "Shawl Collar": "b60157015", "Christmas & Holiday Sweaters": "b60184365", "Merino Wool": "b60157018", "V-Neck": "b60137707", "Sweater Vests": "b60157361", "Sweatshirts": "b60153715", "Crewneck": "b60137705", "Cashmere": "b60137708", "Cardigans": "b60137704", "Wool Sweaters": "b60153719", "Zip Up": "b60144717", "Cotton": "b60153717"], "PANTS": ["Corduroys": "b60179396", "Chinos": "b60179394", "Ski & Snowboard Pants": "b60183199", "Dress Pants": "b60137714", "Five Pocket Pants": "b60179398", "Jogger Pants": "b60179141", "Workout Pants": "b60180854", "Casual Pants": "b60142699", "Cargo Pants": "b60179391"]], "Women": ["Shoes": ["Evening": "b2377052", "Athletic": "b6015208", "Comfort": "b2374961", "Boots": "b60139933", "Flats": "b2376184", "Sneakers": "b6015208", "Booties": "b60167688", "Wedges": "b60177734", "Pumps": "b60139935", "Sandals": "b2372949", "Slippers": "b6014060"], "SHORTS": ["Jean Shorts": "b60164645", "Bermuda Shorts": "b60164703", "High Waisted Shorts": "b60164702"], "JEANS": ["High Waisted Jeans": "b60177060", "Jeggings": "b6023607", "Boyfriend Jeans": "b60138002", "Flared Jeans": "b60138004", "Skinny Jeans": "b60138009", "Bootcut Jeans": "b60138000", "Jean Shorts": "b60138007", "Cropped Jeans": "b60138003", "Ankle Jeans": "b60164113"], "TOPS": ["Tank Tops": "b60140279", "Blouses": "b60140275", "Wrap Blouses": "b60170685", "Night Out Tops": "b60145998", "Button Down Shirts": "b60140276", "Crop Tops": "b60145996", "Plaid Shirts": "b60183089", "Graphic Tees": "b60151023", "Lace Tops": "b60167867", "Tunics": "b60140281", "Sweatshirts": "b60140278", "T-Shirts": "b60140280"], "COATS": ["Rain Coats": "b60171431", "Down Coats": "b60171461", "Vests": "b60175297", "Peacoats": "b60171457", "Wool Coats": "b60171462", "Utility Coats": "b60140009", "Puffer Coats": "b60171455", "Quilted Coats": "b60171454", "Trench Coats": "b60171432", "Parkas": "b60171452"], "DRESSES": ["Party Dresses": "b2374331", "Lace Dresses": "b60160342", "Casual Dresses": "b60145633", "Jumpsuits & Rompers": "b60167202", "Vacation Dresses": "b60184099", "Formal Dresses": "b60139442", "Work Dresses": "b60145634", "Sweater Dresses": "b60156074", "Midi Dresses": "b60176345", "Club Dresses": "b60173514", "Day Dresses": "b60139440", "Bodycon Dresses": "b60145635", "Fit and Flare Dresses": "b60161703", "White Dresses": "b60161704", "Cocktail Dresses": "b60188386", "Bridesmaid Dresses": "b60139438", "Maxi Dresses": "b60139999", "Wedding Guest Dresses": "b60139443"], "JACKETS": ["Blazers": "b60140010", "Jean Jackets": "b60171647", "Bomber Jackets": "b60171649", "Tweed Jackets": "b60169317", "Motorcycle Jackets": "b60177191", "Military Jackets": "b60178309"], "SWEATERS": ["V-Neck Sweaters": "b60154118", "Crewneck Sweaters": "b60154117", "Cashmere Sweaters": "b60154115", "Tunic Sweaters": "b60175558", "Turtlenecks": "b60154120", "Cardigans": "b60170024"], "SKIRTS": ["A Line Skirts": "b60140333", "Pencil Skirts": "b60140335", "Skater Skirts": "b60151035", "Mini Skirts": "b60140337", "Jean Skirts": "b60179622", "Midi Skirts": "b60140338", "Bodycon Skirts": "b60151037"], "PANTS": ["Printed Pants": "b60152396", "Cropped Pants": "b60145870", "Leggings": "b60140014", "Skinny Pants": "b60145873"]]]
    
    for store in ["Nordstroms"]{
      let aStore = AMRInventoryCategory(name: store)
      aStore.subcategories = []
      for (cat1, cat1Data) in nordstromData {
        let aCat1 = AMRInventoryCategory(name: cat1)
        aCat1.subcategories = []
        for (cat2, cat2Data) in cat1Data {
          let aCat2 = AMRInventoryCategory(name: cat2)
          aCat2.subcategories = []
          for (cat3, cat3Data) in cat2Data {
            let aCat3 = AMRInventoryCategory(name: cat3)
            aCat3.items = []
            getItemsForCategory(cat3Data) { (items: [AMRInventoryItem]) in
              aCat3.items = items
            }
            aCat2.subcategories!.append(aCat3)
          }
          aCat1.subcategories!.append(aCat2)
        }
        aStore.subcategories!.append(aCat1)
      }
      inventory.categories.append(aStore)
    }
    completion(inventory: inventory)
  }
}

func getItemsForCategory(category:String, completion: ([AMRInventoryItem]) -> ()) {
  let urlString = "http://shop.nordstrom.com/FashionSearch.axd?category=\(category)&contextualsortcategoryid=0&instoreavailability=false&page=2&pagesize=100&partial=1&sizeFinderId=2&type=category"
  
  let url = NSURL(string: urlString)
  let request = NSURLRequest(URL:url!)
  
  NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()) { (response, dataOrNil, errorOrNil) -> Void in
    if let data = dataOrNil {
      var items: [AMRInventoryItem] = []
      let object = try! NSJSONSerialization.JSONObjectWithData(data, options: [])
      let fashions = object["Fashions"] as! [NSDictionary]
      for item in fashions {
        let name = item["Title"] as! String
        let imageUrl = "http://g.nordstromimage.com/imagegallery/store/product/Medium" + (item["PhotoPath"] as! String)
        let id = String(item["Id"])
        let price = item["OriginalMaximumPrice"] as! Float
        let item = AMRInventoryItem(name: name, imageUrl: imageUrl, id: id, price: price)
        items.append(item)
      }
      completion(items)
    } else {
      if let error = errorOrNil {
        NSLog("Error: \(error)")
      }
    }
  }
}

class AMRInventoryCategory {
  var name: String?
  var imageUrl: String?
  var items: [AMRInventoryItem]?
  var subcategories: [AMRInventoryCategory]?
  init(name:String?, imageUrl: String?){
    self.name = name
    self.imageUrl = imageUrl
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
