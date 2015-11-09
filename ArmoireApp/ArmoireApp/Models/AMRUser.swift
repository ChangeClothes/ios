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
  @NSManaged var stylist: AMRUser?
  @NSManaged var profilePhoto: AMRImage?
  
  var fullName: String {
    get{
      return firstName + " " + lastName
    }
  }
  
  override class func currentUser() -> AMRUser? {
    return PFUser.currentUser() as? AMRUser
  }
 
  var _avatarImage: UIImage?
  
  func setAvatarImage(callback:(avatarDidChange: Bool) -> ()){
    self.profilePhoto?.fetchIfNeededInBackgroundWithBlock({ (imageObject: PFObject?, error:NSError?) -> Void in
      if let photo = imageObject as! AMRImage? {
        photo.getImage({ (image: UIImage) -> () in
          let avatarDidChange = self.avatarImage == nil
          self._avatarImage = image
          callback(avatarDidChange: avatarDidChange)
        })
      }
    })
  }
  
  override init(){
    super.init()
    self.fetchIfNeededInBackground()
  }

  override init(className newClassName: String) {
    super.init(className: newClassName)
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
  
  func setCurrentUser(){
    user = AMRUser.currentUser()
    self.user?.fetchIfNeededInBackgroundWithBlock({ (obj, err) -> Void in
      if let userPhoto = self.user?.profilePhoto{
        userPhoto.fetchIfNeededInBackground()
      }
    })
  }
  
  @objc func didLogin(sender: NSNotification) {
      setCurrentUser()
  }
}