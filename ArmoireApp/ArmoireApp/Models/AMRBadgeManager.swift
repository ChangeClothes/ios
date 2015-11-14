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
}

class AMRBadgeManager: NSObject {
  var layerQueryController: LYRQueryController!
  
  // MARK: - Shared Instance
  static let sharedInstance = AMRBadgeManager()
  
  var layerClient: LYRClient! {
    didSet {
      setupLayerQueryControllerForUnreadConversations()
    }
  }
  
  var clientBadges = [AMRUser: AMRClientBadges]()
  private var getClientBadgesCompletion: (([AMRUser: AMRClientBadges]) -> Void)?
  private let numberOfClientChecks = 3
  private var clientBadgesCountdown: Int! {
    didSet {
      print(clientBadgesCountdown)
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
    clientBadges = [AMRUser: AMRClientBadges]()
    AMRUserManager.sharedManager.queryForAllClientsOfStylist(stylist) { (clients: NSArray?, error: NSError?) -> Void in
      
      if let error = error {
        print(error.localizedDescription)
      } else {
        if let amrClients = clients as? [AMRUser] {
          
          self.clientBadgesCountdown = amrClients.count * self.numberOfClientChecks
          
          for client in amrClients {
            // Check for unrated images
            self.determineUnratedImageBadgesForClient(client)
            self.determineMeetingTodayBadgeForClient(client)
            self.determineUnreadConversationForClient(client)
          }
        }
      }
    }
    
  }
  
  private func determineUnratedImageBadgesForClient(client: AMRUser){
    AMRImage.imagesForUser(nil, client: client, completion: { (objects, error) -> Void in
      if let error = error {
        print(error.localizedDescription)
      } else {
        if let images = objects {
          for image in images{
            if image.rating == AMRPhotoRating.Unrated {
              if let badges = self.clientBadges[client] {
                badges.hasUnratedPhotos = true
              } else {
                self.clientBadges[client] = AMRClientBadges()
                self.clientBadges[client]?.hasUnratedPhotos = true
              }
            }
          }
          self.clientBadgesCountdown = self.clientBadgesCountdown - 1
        }
      }
    })
  }
  
  private func determineMeetingTodayBadgeForClient(client: AMRUser){
    let cal = NSCalendar.currentCalendar()
    let components = cal.components([.Era, .Year, .Month, .Day], fromDate: NSDate())
    let today = cal.dateFromComponents(components)
    
    AMRMeeting.meetingArrayForStylist(nil, client: client) { (objects, error) -> Void in
      if let error = error {
        print(error.localizedDescription)
      } else {
        if let meetings = objects {
          for meeting in meetings{
            let startDateComponents = cal.components([.Era, .Year, .Month, .Day], fromDate: meeting.startDate)
            let meetingDay = cal.dateFromComponents(startDateComponents)
            if today!.isEqualToDate(meetingDay!) == true {
              if let badges = self.clientBadges[client] {
                badges.hasMeetingToday = true
              } else {
                self.clientBadges[client] = AMRClientBadges()
                self.clientBadges[client]?.hasMeetingToday = true
              }
            }
          }
          self.clientBadgesCountdown = self.clientBadgesCountdown - 1
        }
      }
      
    }
  }
  
  private func determineUnreadConversationForClient(client: AMRUser) {
    let query = LYRQuery(queryableClass: LYRMessage.self)
    let unreadPredicate = LYRPredicate(property: "isUnread", predicateOperator: LYRPredicateOperator.IsEqualTo, value: true)
    let userPredicate = LYRPredicate(property: "sender.userID", predicateOperator: LYRPredicateOperator.IsEqualTo, value: client.objectId)
    
    query.predicate = LYRCompoundPredicate(type: LYRCompoundPredicateType.And, subpredicates: [userPredicate, unreadPredicate])
    
    layerClient.executeQuery(query) { (conversations: NSOrderedSet!, error: NSError!) -> Void in
      if let error = error {
        print(error.localizedDescription)
      } else {
        if conversations.count != 0 {
          if let badges = self.clientBadges[client] {
            badges.hasUnreadMessages = true
          } else {
            self.clientBadges[client] = AMRClientBadges()
            self.clientBadges[client]?.hasUnreadMessages = true
          }
        }
        self.clientBadgesCountdown = self.clientBadgesCountdown - 1
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
