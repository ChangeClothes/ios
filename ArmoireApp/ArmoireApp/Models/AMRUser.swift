//
//  AMRUser.swift
//  ArmoireApp
//
//  Created by Randy Ting on 10/21/15.
//  Copyright © 2015 Armoire. All rights reserved.
//

import UIKit

class AMRUser: PFUser {
  
  @NSManaged var isStylist: Bool
  @NSManaged var firstName: String
  @NSManaged var lastName: String
  @NSManaged var fullName: String
  @NSManaged var stylist: AMRUser
  
  override class func currentUser() -> AMRUser? {
    return PFUser.currentUser() as? AMRUser
  }
  
}
