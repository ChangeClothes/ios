//
//  AMRBadgeManager.swift
//  ArmoireApp
//
//  Created by Randy Ting on 11/11/15.
//  Copyright © 2015 Armoire. All rights reserved.
//

import UIKit

let kUserConversationsChanged = "com.ArmoireApp.userConversationsChanged"

class AMRClientBadges {
  var hasUnreadMessages = false
  var hasUnratedPhotos = false
  var hasMeetingToday = false
  
  class func hasUnreadMessagesOnly() -> AMRClientBadges {
    let result = AMRClientBadges()
    result.hasUnreadMessages = true
    return result
  }
  
  func isEqualTo(otherClientBadge: AMRClientBadges) -> Bool {
    if self.hasUnreadMessages == otherClientBadge.hasUnreadMessages &&
    self.hasMeetingToday == otherClientBadge.hasMeetingToday &&
      self.hasUnratedPhotos == otherClientBadge.hasUnratedPhotos {
        return true
    }
    
    return false
  }
}

class AMRBadgeManager: NSObject {
  var layerQueryController: LYRQueryController!
  var meetingsToday: [AMRMeeting]!
  
  var clients: [AMRUser] = []
  
  // MARK: - Shared Instance
  static let sharedInstance = AMRBadgeManager()
  
  var layerClient: LYRClient! {
    didSet {
      setupLayerQueryControllerForUnreadConversations()
    }
  }
  
  var clientBadges: [AMRUser: AMRClientBadges] {
    get{
      var badges =  [AMRUser: AMRClientBadges]()
      
      for client in clients{
        if let badge = tempBadges[client.objectId!]{
          if badge.hasMeetingToday || badge.hasUnratedPhotos || badge.hasUnreadMessages {
            badges[client] = tempBadges[client.objectId!]
          }
        }
      }
      return badges
    }
  }
  
  var tempBadges = [String: AMRClientBadges]()
  private var getClientBadgesCompletion: (([AMRUser: AMRClientBadges]) -> Void)?
  private let numberOfClientChecks = 3
  private var clientBadgesCountdown: Int! {
    didSet {
      if clientBadgesCountdown == 0 {
        getClientBadgesCompletion?(clientBadges)
      }
    }
  }

  // MARK: - Stylist Badges
  var numberOfUnreadConversations: Int?
  // Don't need to calculate this
  
  private func setupLayerQueryControllerForUnreadConversations(){
    let query = LYRQuery(queryableClass: LYRConversation.self)
    query.predicate = LYRPredicate(property: "hasUnreadMessages", predicateOperator: LYRPredicateOperator.IsEqualTo, value: true)
    layerQueryController = try? layerClient!.queryControllerWithQuery(query, error: ())
    layerQueryController!.delegate = self
    layerQueryController!.executeWithCompletion { (success: Bool, error: NSError!) -> Void in
      if let error = error {
        print(error.localizedDescription)
      } else {
        NSNotificationCenter.defaultCenter().postNotificationName(kUserConversationsChanged, object: self)
      }
    }
  }
  
  // MARK: - Stylists Client View Badges
  var numberOfUnreadMessagesForStylist: Int?
  
  // MARK: - Client View Badges
  //  var numberOfAppointmentsToday: Int?
  var numberOfUnreadMessages: Int?
  
  // MARK: - Shared Stylist and Client Badge
  var numberOfUnratedPhotos: Int?
  
  // MARK: - Today Client List
  func getClientBadgesForStylist(stylist: AMRUser, withCompletion completion: ((clientBadges: [AMRUser: AMRClientBadges]) -> Void)?) {
    getClientBadgesCompletion = completion
    AMRUserManager.sharedManager.queryForAllClientsOfStylist(stylist) { (clients: NSArray?, error: NSError?) -> Void in
      
      if let error = error {
        print(error.localizedDescription)
      } else {
        if let amrClients = clients as? [AMRUser] {
          self.clients = amrClients
          
          for client in amrClients{
            self.tempBadges[client.objectId!] = AMRClientBadges()
          }
          
          self.clientBadgesCountdown = self.numberOfClientChecks + amrClients.count - 1
          
          self.determineUnratedImageBadgesForStylist(stylist)
          self.determineMeetingTodayBadgeForStylist(stylist)
          self.determineUnreadConversationForStylist(stylist)
          
        }
      }
    }
  }
  
  private func determineUnratedImageBadgesForStylist(stylist: AMRUser){
    AMRImage.imagesForUser(stylist, client:nil, completion: { (objects, error) -> Void in
      if let error = error {
        print(error.localizedDescription)
      } else {
        if let images = objects {
          for image in images{
            if image.rating == AMRPhotoRating.Unrated {
              if let client = image.client {
                if let badges = self.tempBadges[client.objectId!] {
                  badges.hasUnratedPhotos = true
                } else {
                  self.tempBadges[client.objectId!] = AMRClientBadges()
                  self.tempBadges[client.objectId!]?.hasUnratedPhotos = true
                }
              }
            }
          }
          self.clientBadgesCountdown = self.clientBadgesCountdown - 1
        }
      }
    })
  }
  
  private func determineMeetingTodayBadgeForStylist(stylist: AMRUser){
    let cal = NSCalendar.currentCalendar()
    let components = cal.components([.Era, .Year, .Month, .Day], fromDate: NSDate())
    let today = cal.dateFromComponents(components)
    meetingsToday = [AMRMeeting]()
    
    AMRMeeting.meetingArrayForStylist(stylist, client: nil) { (objects, error) -> Void in
      if let error = error {
        print(error.localizedDescription)
      } else {
        if let meetings = objects {
          for meeting in meetings{
            let startDateComponents = cal.components([.Era, .Year, .Month, .Day], fromDate: meeting.startDate)
            let meetingDay = cal.dateFromComponents(startDateComponents)
            if today!.isEqualToDate(meetingDay!) == true {
              let client = meeting.client
              self.meetingsToday.append(meeting)
              if let badges = self.tempBadges[client.objectId!] {
                badges.hasMeetingToday = true
              } else {
                self.tempBadges[client.objectId!] = AMRClientBadges()
                self.tempBadges[client.objectId!]?.hasMeetingToday = true
              }
            }
          }
          self.clientBadgesCountdown = self.clientBadgesCountdown - 1
        }
      }
      
    }
  }
  
  private func determineUnreadConversationForStylist(stylist: AMRUser) {
    for client in clients{
      let query = LYRQuery(queryableClass: LYRMessage.self)
      let unreadPredicate = LYRPredicate(property: "isUnread", predicateOperator: LYRPredicateOperator.IsEqualTo, value: true)
      let userPredicate = LYRPredicate(property: "sender.userID", predicateOperator: LYRPredicateOperator.IsEqualTo, value: client.objectId)
      query.predicate = LYRCompoundPredicate(type: LYRCompoundPredicateType.And, subpredicates: [userPredicate, unreadPredicate])
      
      layerClient.countForQuery(query) { (count: UInt, error:NSError!) -> Void in
        if let error = error {
          print(error.localizedDescription)
        } else {
          if count > 0 {
            
            if let _ = self.tempBadges[client.objectId!] {
              self.tempBadges[client.objectId!]?.hasUnreadMessages = true
            } else {
              self.tempBadges[client.objectId!] = AMRClientBadges()
              self.tempBadges[client.objectId!]?.hasUnreadMessages = true
            }
          }
          self.clientBadgesCountdown = self.clientBadgesCountdown - 1
        }
      }
    }
  }
}

// MARK: - LYRQueryController Delegate

extension AMRBadgeManager: LYRQueryControllerDelegate {
  func queryControllerDidChangeContent(queryController: LYRQueryController!) {
    NSNotificationCenter.defaultCenter().postNotificationName(kUserConversationsChanged, object: self)
  }
}
