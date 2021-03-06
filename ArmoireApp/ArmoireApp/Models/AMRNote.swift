//
//  AMRNote.swift
//  ArmoireApp
//
//  Created by Morgan Wildermuth on 10/23/15.
//  Copyright © 2015 Armoire. All rights reserved.
//

import UIKit

class AMRNote: PFObject {
  @NSManaged var content: String?
  @NSManaged var client: AMRUser
  @NSManaged var stylist: AMRUser
  
  class func noteForUser(stylist: AMRUser?, client: AMRUser?, completion: (objects: [AMRNote]?, error: NSError?) -> Void)  {
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
      completion(objects: objects as? [AMRNote], error: error)
    })
  }
  
  class func getOrCreateNoteForUser(stylist: AMRUser?, client: AMRUser?, completion: (note: AMRNote?, error: NSError?) -> Void) {
    
    noteForUser(stylist, client: client) { (objects:[AMRNote]?, error: NSError?) -> Void in
      if error != nil {
        completion(note: nil, error: error)
      } else {
        if let notes = objects {
          if notes.count == 0 {
            let note = AMRNote()
            note.stylist = stylist!
            note.client = client!
            note.content = ""
            completion(note: note, error: nil)
          } else {
            let note = notes.first
            completion(note: note, error: nil)
          }
        }
      }
    }
    
  }
  
}

extension AMRNote: PFSubclassing {
  static func parseClassName() -> String {
    return "Note"
  }
  
}