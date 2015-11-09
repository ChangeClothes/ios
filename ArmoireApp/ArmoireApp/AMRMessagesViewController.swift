//
//  AMRMessagesViewController.swift
//  ArmoireApp
//
//  Created by Morgan Wildermuth on 10/18/15.
//  Copyright © 2015 Armoire. All rights reserved.
//

import UIKit
import LayerKit

class AMRMessagesViewController: ATLConversationListViewController{

  var messages: NSDictionary?
  var stylist: AMRUser?
  var client: AMRUser?
  @IBOutlet weak var messagesTable: UITableView!

  // MARK: - Lifecycle

  override func viewDidLoad() {
    
    super.viewDidLoad()
    self.title = "Messages"
    
    // TODO: Remove this when settings button is refactored
    setUpNavBar()
    // End TODO
    
    self.dataSource = self
    self.delegate = self
    
    setupNavigationBar()

    displaysAvatarItem = true
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  // MARK: - Initial setup

  private func setupNavigationBar(){
    let composeItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Compose, target: self, action: Selector("composeButtonTapped:"))
    self.navigationItem.setRightBarButtonItem(composeItem, animated: false)
  }
  
  private func setUpNavBar(){
    if (stylist != nil && client != nil){
      let leftNavBarButton = UIBarButtonItem(image: UIImage(named: "cancel"), style: .Plain, target: self, action: "exitModal")
      self.navigationItem.leftBarButtonItem = leftNavBarButton
    } else {
      let leftNavBarButton = UIBarButtonItem(image: UIImage(named: "settings"), style: .Plain, target: self, action: "onSettingsTap")
      self.navigationItem.leftBarButtonItem = leftNavBarButton
    }
  }

  func exitModal(){
    self.dismissViewControllerAnimated(true, completion: nil)
  }

  // MARK: - Behavior
  func composeButtonTapped(sender: AnyObject) {
    let controller = AMRMessagesDetailsViewController(layerClient: self.layerClient)
    controller.displaysAddressBar = true
    controller.stylist = self.stylist
    controller.client = self.client
    self.navigationController!.pushViewController(controller, animated: true)
  }
  
  // MARK:- Conversation Selection
  
  // The following method handles presenting the correct `AMRMessagesViewController`, regardeless of the current state of the navigation stack.
  func presentControllerWithConversation(conversation: LYRConversation) {
    let shouldShowAddressBar: Bool  = conversation.participants.count > 2 || conversation.participants.count == 0
    var conversationParticipants = conversation.participants
    let conversationViewController: AMRMessagesDetailsViewController = AMRMessagesDetailsViewController(layerClient: self.layerClient)
    conversationParticipants.remove(AMRUser.currentUser()!.objectId!)
    if conversationParticipants.count != 1 {
      print("the participants were more than 1, so identifying missing AMRUser in presentControllerWithConversation did not succeed")
    } else {
      AMRUserManager().queryForUserWithObjectID(conversationParticipants.first! as! String, withCompletion: { (users, error) -> Void in
        if let conversationClient = users![0] as? AMRUser {
          conversationViewController.title = self.stylist!.firstName + " + " + conversationClient.firstName
        }
      })
    }
    conversationViewController.displaysAddressBar = shouldShowAddressBar
    conversationViewController.conversation = conversation
    conversationViewController.stylist = self.stylist
    conversationViewController.client = self.client
    
    if self.navigationController!.topViewController == self {
      self.navigationController!.pushViewController(conversationViewController, animated: true)
    } else {
      var viewControllers = self.navigationController!.viewControllers
      let listViewControllerIndex: Int = self.navigationController!.viewControllers.indexOf(self)!
      viewControllers[listViewControllerIndex + 1 ..< viewControllers.count] = [conversationViewController]
      self.navigationController!.setViewControllers(viewControllers, animated: true)
    }
  }
  
  // TODO: Remove this when settings button in refactored
  func onSettingsTap(){
    let settingsVC = UIAlertController.AMRSettingsController { (AMRSettingsControllerSetting) -> () in}
    self.presentViewController(settingsVC, animated: true, completion: nil)
  }
  
}

// MARK: - ATLConversationListViewController Delegate
extension AMRMessagesViewController: ATLConversationListViewControllerDelegate {
  func conversationListViewController(conversationListViewController: ATLConversationListViewController, didSelectConversation conversation:LYRConversation) {
    self.presentControllerWithConversation(conversation)
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

  internal func setVcData(stylist: AMRUser?, client: AMRUser?) {
    self.stylist = stylist
    self.client = client
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
