//
//  AMRMeeting.swift
//  ArmoireApp
//
//  Created by Randy Ting on 10/18/15.
//  Copyright © 2015 Armoire. All rights reserved.
//

import UIKit

class AMRMeeting: PFObject {
  
  @NSManaged var location: String?
  @NSManaged var startDate: NSDate
  @NSManaged var endDate: NSDate
  @NSManaged var client: AMRUser
  @NSManaged var stylist: AMRUser
  @NSManaged var title: String
  
  class func meetingArrayForStylist(stylist: AMRUser?, client: AMRUser?, completion: (objects: [AMRMeeting]?, error: NSError?) -> Void)  {
    
    let query = self.query()
    if let stylist = stylist {
      query?.whereKey("stylist", equalTo: stylist)
    }
    if let client = client {
      query?.whereKey("client", equalTo: client)
    }
    query?.findObjectsInBackgroundWithBlock({ (objects: [PFObject]?, error: NSError?) -> Void in
      completion(objects: objects as? [AMRMeeting], error: error)
    })
  }
  
  class func deleteMeetingWithObjectId(id: String, completion: (success: Bool, error: NSError?) -> Void) {
    let query = self.query()
    query?.whereKey("objectId", equalTo: id)
    query?.findObjectsInBackgroundWithBlock({ (meetings: [PFObject]?, error: NSError?) -> Void in
      if let error = error {
        print(error.localizedDescription)
      } else {
        let meeting = meetings?.first as? AMRMeeting
        meeting?.deleteInBackgroundWithBlock({ (success: Bool, error: NSError?) -> Void in
          if let error = error {
            print(error.localizedDescription)
            completion(success: false, error: error)
          } else {
            print("Deleted \(meeting)")
            completion(success: true, error: nil)
          }
        })
      }
    })
  }
  
  class func meetingWithObjectId(objectId: String?, completion: (meeting: AMRMeeting?, error: NSError?) -> Void){
    let query = self.query()
    query?.whereKey("objectId", equalTo: objectId!)
    query?.findObjectsInBackgroundWithBlock({ (meetings: [PFObject]?, error: NSError?) -> Void in
      if let error = error {
        completion(meeting: nil, error: error)
      } else {
        let meeting = meetings?.first as! AMRMeeting
        completion(meeting: meeting, error: nil)
      }
    })
  }
}

extension AMRMeeting: PFSubclassing {
  static func parseClassName() -> String {
    return "Meeting"
  }
  
}