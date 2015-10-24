//
//  AMRMessagesViewController.swift
//  ArmoireApp
//
//  Created by Morgan Wildermuth on 10/18/15.
//  Copyright © 2015 Armoire. All rights reserved.
//

import UIKit
import LayerKit

class AMRMessagesViewController: ATLConversationListViewController {

  var stylist: AMRUser?
  var client: AMRUser?
  
  // MARK: - Lifecycle
  override func viewDidLoad() {
    
    super.viewDidLoad()
    self.title = "Messages"
    var settings: UIButton = UIButton()
    settings.setImage(UIImage(named: "settings"), forState: .Normal)
    settings.frame = CGRectMake(0, 0, 30, 30)
    settings.addTarget(self, action: Selector("onSettingsTap"), forControlEvents: .TouchUpInside)
    
    var leftNavBarButton = UIBarButtonItem(customView: settings)
    self.navigationItem.leftBarButtonItem = leftNavBarButton
    
    self.dataSource = self
    self.delegate = self

    displaysAvatarItem = true
    
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "userDidLogin:", name: kUserDidLoginNotification, object: nil)
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  func onSettingsTap(){
    let settingsVC = AMRSettingsViewController()
    navigationController?.pushViewController(settingsVC, animated: true)
  }
  
  func userDidLogin(sender: NSNotification) {
    tableView.reloadData()
  }

}

// MARK: - ATLConversationListViewController Delegate
extension AMRMessagesViewController: ATLConversationListViewControllerDelegate {
  func conversationListViewController(conversationListViewController: ATLConversationListViewController, didSelectConversation conversation:LYRConversation) {
//    self.presentControllerWithConversation(conversation)
  }
  
  func conversationListViewController(conversationListViewController: ATLConversationListViewController, didDeleteConversation conversation: LYRConversation, deletionMode: LYRDeletionMode) {
    print("Conversation deleted")
  }
  
  func conversationListViewController(conversationListViewController: ATLConversationListViewController, didFailDeletingConversation conversation: LYRConversation, deletionMode: LYRDeletionMode, error: NSError?) {
    print("Failed to delete conversation with error: \(error)")
  }
  
  func conversationListViewController(conversationListViewController: ATLConversationListViewController, didSearchForText searchText: String, completion: ((Set<NSObject>!) -> Void)?) {
    AMRUserManager.sharedManager.queryForUserWithName(searchText) { (participants: NSArray?, error: NSError?) in
      if error == nil {
        if let callback = completion {
          callback(NSSet(array: participants as! [AnyObject]) as Set<NSObject>)
        }
      } else {
        if let callback = completion {
          callback(nil)
        }
        print("Error searching for Users by name: \(error)")
      }
    }
  }
  
  func conversationListViewController(conversationListViewController: ATLConversationListViewController!, avatarItemForConversation conversation: LYRConversation!) -> ATLAvatarItem! {
    let userID: String = conversation.lastMessage.sender.userID
    if userID == AMRUser.currentUser()!.objectId {
      return AMRUser.currentUser()
    }
    let user: AMRUser? = AMRUserManager.sharedManager.cachedUserForUserID(userID)
    if user == nil {
      AMRUserManager.sharedManager.queryAndCacheUsersWithIDs([userID], completion: { (participants, error) in
        if participants != nil && error == nil {
          self.reloadCellForConversation(conversation)
        } else {
          print("Error querying for users: \(error)")
        }
      })
    }
    return user;
  }

}

// MARK: - ATLConversationListViewController Datasource
extension AMRMessagesViewController: ATLConversationListViewControllerDataSource {
  
  func conversationListViewController(conversationListViewController: ATLConversationListViewController, titleForConversation conversation: LYRConversation) -> String {
    if conversation.metadata["title"] != nil {
      return conversation.metadata["title"] as! String
    } else {
      let listOfParticipant = Array(conversation.participants)
      let unresolvedParticipants: NSArray = AMRUserManager.sharedManager.unCachedUserIDsFromParticipants(listOfParticipant)
      let resolvedNames: NSArray = AMRUserManager.sharedManager.resolvedNamesFromParticipants(listOfParticipant)
      
      if (unresolvedParticipants.count > 0) {
        AMRUserManager.sharedManager.queryAndCacheUsersWithIDs(unresolvedParticipants as! [String]) { (participants: NSArray?, error: NSError?) in
          if (error == nil) {
            if (participants?.count > 0) {
              self.reloadCellForConversation(conversation)
            }
          } else {
            print("Error querying for Users: \(error)")
          }
        }
      }
      
      if (resolvedNames.count > 0 && unresolvedParticipants.count > 0) {
        let resolved = resolvedNames.componentsJoinedByString(", ")
        return "\(resolved) and \(unresolvedParticipants.count) others"
      } else if (resolvedNames.count > 0 && unresolvedParticipants.count == 0) {
        return resolvedNames.componentsJoinedByString(", ")
      } else {
        return "Conversation with \(conversation.participants.count) users..."
      }
    }
  }

}
