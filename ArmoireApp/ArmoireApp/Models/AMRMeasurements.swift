//
//  AMRMeasurements.swift
//  ArmoireApp
//
//  Created by Mathew Kellogg on 10/28/15.
//  Copyright © 2015 Armoire. All rights reserved.
//

class AMRMeasurements: PFObject {
  @NSManaged var measurements: [[String:String]]
  @NSManaged var client: AMRUser
  @NSManaged var stylist: AMRUser
  
  class func measurementsForUser(stylist: AMRUser?, client: AMRUser?, completion: (object: AMRMeasurements?, error: NSError?) -> Void)  {
    let query = self.query()
    if let stylist = stylist {
      query?.whereKey("stylist", equalTo: stylist)
    } else {
      query?.whereKeyDoesNotExist("stylist")
    }
    if let client = client {
      query?.whereKey("client", equalTo: client)
    } else {
      query?.whereKeyDoesNotExist("client")
    }
    query?.findObjectsInBackgroundWithBlock({ (objects: [PFObject]?, error: NSError?) -> Void in
      completion(object: objects?.first as? AMRMeasurements, error: error)
    })
  }
}

extension AMRMeasurements: PFSubclassing {
  static func parseClassName() -> String {
    return "Measurement"
  }
  
}