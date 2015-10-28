//
//  AMRUserManager.swift
//  ArmoireApp
//
//  Created by Randy Ting on 10/23/15.
//  Copyright © 2015 Armoire. All rights reserved.
//

import Foundation

class AMRUserManager {
  static let sharedManager = AMRUserManager()
  var userCache: NSCache = NSCache()
  
  // MARK Query Methods
  func queryForUserWithName(searchText: String, completion: ((NSArray?, NSError?) -> Void)) {
    let query: PFQuery! = AMRUser.query()
    query.whereKey("objectId", notEqualTo: AMRUser.currentUser()!.objectId!)

    query.findObjectsInBackgroundWithBlock { objects, error in
      var contacts = [AMRUser]()
      if (error == nil) {
        for user: AMRUser in (objects as! [AMRUser]) {
          if user.fullName.rangeOfString(searchText, options: NSStringCompareOptions.CaseInsensitiveSearch) != nil {
            contacts.append(user)
          }
        }
      }
      completion(contacts, error)
    }
  }

  func queryForStylistWithName(searchText: String, completion: ((NSArray?, NSError?) -> Void)) {
    let query: PFQuery! = AMRUser.query()
    query.whereKey("objectId", notEqualTo: AMRUser.currentUser()!.objectId!)
    query.whereKey("stylist", equalTo: AMRUser.currentUser()!)
    
    query.findObjectsInBackgroundWithBlock { objects, error in
      var contacts = [AMRUser]()
      if (error == nil) {
        for user: AMRUser in (objects as! [AMRUser]) {
          if user.fullName.rangeOfString(searchText, options: NSStringCompareOptions.CaseInsensitiveSearch) != nil {
            contacts.append(user)
          }
        }
      }
      completion(contacts, error)
    }
  }
  
  func queryForAllUsersWithCompletion(completion: ((NSArray?, NSError?) -> Void)?) {
    let query: PFQuery! = AMRUser.query()
    query.whereKey("objectId", notEqualTo: AMRUser.currentUser()!.objectId!)
    query.findObjectsInBackgroundWithBlock { objects, error in
      if let callback = completion {
        callback(objects, error)
      }
    }
  }
  
  func queryForAllClientsOfStylist(stylist: AMRUser, completion: ((NSArray?, NSError?) -> Void)?) {
    if stylist.isStylist {
      let query: PFQuery! = AMRUser.query()
      query.whereKey("stylist", equalTo: stylist)
      query.findObjectsInBackgroundWithBlock { objects, error in
        if let callback = completion {
          callback(objects, error)
        }
      }
    } else {
      let userInfo =
      [
        NSLocalizedDescriptionKey: "User is not a stylist",
        NSLocalizedFailureReasonErrorKey: "Only stylists' have clients.",
        NSLocalizedRecoverySuggestionErrorKey: "Please make sure that user is a stylist."
      ]
      let error = NSError(domain: AMRErrorDomain, code: 0, userInfo: userInfo)
      completion?(nil,error)
    }

  }
  
  func queryAndCacheUsersWithIDs(userIDs: [String], completion: ((NSArray?, NSError?) -> Void)?) {
    let query: PFQuery! = AMRUser.query()
    query.whereKey("objectId", containedIn: userIDs)
    query.findObjectsInBackgroundWithBlock { objects, error in
      if (error == nil) {
        for user: AMRUser in (objects as! [AMRUser]) {
          self.cacheUserIfNeeded(user)
        }
      }
      if let callback = completion {
        callback(objects, error)
      }
    }
  }
  
  func cachedUserForUserID(userID: NSString) -> AMRUser? {
    if self.userCache.objectForKey(userID) != nil {
      return self.userCache.objectForKey(userID) as! AMRUser?
    }
    return nil
  }
  
  func cacheUserIfNeeded(user: AMRUser) {
    if self.userCache.objectForKey(user.objectId!) == nil {
      self.userCache.setObject(user, forKey: user.objectId!)
    }
  }
  
  func unCachedUserIDsFromParticipants(participants: NSArray) -> NSArray {
    var array = [String]()
    for userID: String in (participants as! [String]) {
      if (userID == AMRUser.currentUser()!.objectId!) {
        continue
      }
      if self.userCache.objectForKey(userID) == nil {
        array.append(userID)
      }
    }
    
    return NSArray(array: array)
  }
  
  func resolvedNamesFromParticipants(participants: NSArray) -> NSArray {
    var array = [String]()
    for userID: String in (participants as! [String]) {
      if (userID == AMRUser.currentUser()!.objectId!) {
        continue
      }
      if self.userCache.objectForKey(userID) != nil {
        let user: AMRUser = self.userCache.objectForKey(userID) as! AMRUser
        array.append(user.firstName)
      }
    }
    return NSArray(array: array)
  }

}
