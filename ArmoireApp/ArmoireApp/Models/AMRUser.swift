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
  @NSManaged var stylist: AMRUser
  @NSManaged var profilePhoto: AMRImage

  var fullName: String {
    get{
      return firstName + " " + lastName
    }
  }
  
  override class func currentUser() -> AMRUser? {
    return PFUser.currentUser() as? AMRUser
  }
  
}

class CurrentUser{
  
  static var sharedInstance = CurrentUser()
  var user: AMRUser?
  
  init() {
    NSNotificationCenter.defaultCenter().addObserver(self, selector:
      "didLogout:", name: kUserDidLogoutNotification, object: nil)
    NSNotificationCenter.defaultCenter().addObserver(self, selector:
      "didLogin:", name: kUserDidLoginNotification, object: nil)
  }
  
  deinit {
    NSNotificationCenter.defaultCenter().removeObserver(self)
  }
  
  @objc func didLogout(sender: NSNotification) {
    user = nil
  }
  
  @objc func didLogin(sender: NSNotification) {
    user = AMRUser.currentUser()!
    CurrentUser.sharedInstance.user?.fetchIfNeededInBackgroundWithBlock({ (obj, err) -> Void in
      CurrentUser.sharedInstance.user?.profilePhoto.fetchIfNeededInBackground()
    })
  }
}