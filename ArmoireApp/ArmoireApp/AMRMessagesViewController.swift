//
//  AMRMessagesViewController.swift
//  ArmoireApp
//
//  Created by Morgan Wildermuth on 10/18/15.
//  Copyright © 2015 Armoire. All rights reserved.
//

import UIKit
import LayerKit

class AMRMessagesViewController: ATLConversationListViewController, AMRViewControllerProtocol{

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
      let exitModalButton: UIButton = UIButton()
      exitModalButton.setImage(UIImage(named: "undo"), forState: .Normal)
      exitModalButton.frame = CGRectMake(0, 0, 30, 30)
      exitModalButton.addTarget(self, action: Selector("exitModal"), forControlEvents: .TouchUpInside)

      let leftNavBarButton = UIBarButtonItem(customView: exitModalButton)
      self.navigationItem.leftBarButtonItem = leftNavBarButton
    } else {
      let settings: UIButton = UIButton()
      settings.setImage(UIImage(named: "settings"), forState: .Normal)
      settings.frame = CGRectMake(0, 0, 30, 30)
      settings.addTarget(self, action: Selector("onSettingsTap"), forControlEvents: .TouchUpInside)

      let leftNavBarButton = UIBarButtonItem(customView: settings)
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
    self.navigationController!.pushViewController(controller, animated: true)
  }
  
  // MARK:- Conversation Selection
  
  // The following method handles presenting the correct `AMRMessagesViewController`, regardeless of the current state of the navigation stack.
  func presentControllerWithConversation(conversation: LYRConversation) {
    let shouldShowAddressBar: Bool  = conversation.participants.count > 2 || conversation.participants.count == 0
    let conversationViewController: AMRMessagesDetailsViewController = AMRMessagesDetailsViewController(layerClient: self.layerClient)
    conversationViewController.displaysAddressBar = shouldShowAddressBar
    conversationViewController.conversation = conversation
    
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
