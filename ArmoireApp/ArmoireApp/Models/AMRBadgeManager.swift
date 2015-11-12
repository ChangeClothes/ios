//
//  AMRBadgeManager.swift
//  ArmoireApp
//
//  Created by Randy Ting on 11/11/15.
//  Copyright © 2015 Armoire. All rights reserved.
//

import UIKit


class AMRClientBadges {
  var hasUnreadMessages = false
  var hasUnratedPhotos = false
  var hasMeetingToday = false
}

class AMRBadgeManager: NSObject {
  
  // MARK: - Shared Instance
  static let sharedInstance = AMRBadgeManager()
  
  var clientBadges = [AMRUser: AMRClientBadges]()
  private var getClientBadgesCompletion: (() -> Void)?
  private let numberOfClientChecks = 2
  private var clientBadgesCountdown: Int! {
    didSet {
      print(clientBadgesCountdown)
      if clientBadgesCountdown == 0 {
        for (client, badges) in clientBadges {
          print("\(client) \(badges.hasMeetingToday) \(badges.hasUnratedPhotos) \(badges.hasUnreadMessages)")
        }
        getClientBadgesCompletion?()
      }
    }
  }
  
  
  // MARK: - Stylist Badges
  var numberOfUnreadConversations: Int?
  // Don't need to calculate this
  
  // MARK: - Stylists Client View Badges
  var numberOfUnreadMessagesForStylist: Int?
  
  // MARK: - Client View Badges
  //  var numberOfAppointmentsToday: Int?
  var numberOfUnreadMessages: Int?
  
  // MARK: - Shared Stylist and Client Badge
  var numberOfUnratedPhotos: Int?
  
  // MARK: - Today Client List
  func getClientBadgesForStylist(stylist: AMRUser, withCompletion completion: (() -> Void)?) {
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
  
  
}
