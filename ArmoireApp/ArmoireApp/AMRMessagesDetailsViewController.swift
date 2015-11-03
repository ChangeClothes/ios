//
//  AMRMessagesDetailsViewController.swift
//  ArmoireApp
//
//  Created by Morgan Wildermuth on 10/18/15.
//  Copyright © 2015 Armoire. All rights reserved.
//

import UIKit
import LayerKit

class AMRMessagesDetailsViewController: ATLConversationViewController {
  var dateFormatter: NSDateFormatter = NSDateFormatter()
  var usersArray: NSArray!
  var stylist: AMRUser?
  var client: AMRUser?
  
  // MARK: - Lifecycle

  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(false)
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    if (self.client == nil) {
      NSNotificationCenter.defaultCenter().postNotificationName(AMRMainHideMenuView, object: self)
    } else {
      if let stylist = self.stylist {
        self.title = stylist.firstName + " + " + (self.client?.firstName)!
      } else {
        AMRUserManager.sharedManager.queryForUserWithObjectID(self.client!.stylist.objectId!) { (users: NSArray?, error: NSError?) -> Void in
          if let error = error {
            print(error.localizedDescription)
          } else {
            let stylist = users!.firstObject! as! AMRUser
            self.title = stylist.firstName + " + " + (self.client?.firstName)!
          }

        }
      }
    }
    self.dataSource = self
    self.delegate = self
    self.addressBarController?.delegate = self
    
    // Uncomment the following line if you want to show avatars in 1:1 conversations
    // self.shouldDisplayAvatarItemForOneOtherParticipant = true
    
    // Setup the dateformatter used by the dataSource.
    self.dateFormatter.dateStyle = NSDateFormatterStyle.ShortStyle
    self.dateFormatter.timeStyle = NSDateFormatterStyle.ShortStyle
    self.setUpNavBar()
    self.configureUI()
  }
  
  override func viewWillDisappear(animated: Bool) {
    if (self.client == nil){
      NSNotificationCenter.defaultCenter().postNotificationName(AMRMainShowMenuView, object: self)
    }

  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  // MARK - UI Configuration methods
  
  private func setUpNavBar(){
      if (client != nil){
        let leftNavBarButton = UIBarButtonItem(image: UIImage(named: "cancel"), style: .Plain, target: self, action: "exitModal")
        self.navigationItem.leftBarButtonItem = leftNavBarButton
      }
  }

  func configureUI() {
    ATLOutgoingMessageCollectionViewCell.appearance().messageTextColor = UIColor.whiteColor()
  }
  
  // MARK - Transition Methods

  func exitModal(){
    self.dismissViewControllerAnimated(true, completion: nil)
  }

  // MARK - ATLAddressBarViewController Delegate methods methods
  
  override func addressBarViewController(addressBarViewController: ATLAddressBarViewController, didTapAddContactsButton addContactsButton: UIButton) {
    AMRUserManager.sharedManager.queryForAllClientsOfStylist(AMRUser.currentUser()!) { (users: NSArray?, error: NSError?) -> Void in
      if error == nil {
        let participants = NSSet(array: users as! [AMRUser]) as Set<NSObject>
        let controller = AMRParticipantTableViewController(participants: participants, sortType: ATLParticipantPickerSortType.FirstName)
        controller.delegate = self
        
        let navigationController = UINavigationController(rootViewController: controller)
        self.navigationController!.presentViewController(navigationController, animated: true, completion: nil)
      } else {
        print("Error querying for All Users: \(error)")
      }
    }
  
  }
  
  override func addressBarViewController(addressBarViewController: ATLAddressBarViewController, searchForParticipantsMatchingText searchText: String, completion: (([AnyObject]) -> Void)?) {
    AMRUserManager.sharedManager.queryForStylistWithName(searchText) { (participants: NSArray?, error: NSError?) in
      if (error == nil) {
        if let callback = completion {
          callback(participants! as [AnyObject])
        }
      } else {
        print("Error search for participants: \(error)")
      }
    }
  }

  
}

// MARK: - ATLConversationViewController Delegate Methods
extension AMRMessagesDetailsViewController: ATLConversationViewControllerDelegate {
  func conversationViewController(viewController: ATLConversationViewController, didSendMessage message: LYRMessage) {
    print("Message sent!")
  }
  
  func conversationViewController(viewController: ATLConversationViewController, didFailSendingMessage message: LYRMessage, error: NSError?) {
    print("Message failed to sent with error: \(error)")
  }
  
  func conversationViewController(viewController: ATLConversationViewController, didSelectMessage message: LYRMessage) {
    print("Message selected")
  }

}

// MARK: - ATLConversationViewController Datasource Methods
extension AMRMessagesDetailsViewController: ATLConversationViewControllerDataSource {
  func conversationViewController(conversationViewController: ATLConversationViewController, participantForIdentifier participantIdentifier: String) -> ATLParticipant? {
    if (participantIdentifier == AMRUser.currentUser()!.objectId!) {
      return AMRUser.currentUser()!
    }
    let user: AMRUser? = AMRUserManager.sharedManager.cachedUserForUserID(participantIdentifier)
    if (user == nil) {
      AMRUserManager.sharedManager.queryAndCacheUsersWithIDs([participantIdentifier]) { (participants: NSArray?, error: NSError?) -> Void in
        if (participants?.count > 0 && error == nil) {
          self.addressBarController?.reloadView()
          // TODO: Need a good way to refresh all the messages for the refreshed participants...
          self.reloadCellsForMessagesSentByParticipantWithIdentifier(participantIdentifier)
        } else {
          print("Error querying for users: \(error)")
        }
      }
    }
    return user
  }
  
  func conversationViewController(conversationViewController: ATLConversationViewController, attributedStringForDisplayOfDate date: NSDate) -> NSAttributedString? {
    let attributes: NSDictionary = [ NSFontAttributeName : UIFont.systemFontOfSize(14), NSForegroundColorAttributeName : UIColor.grayColor() ]
    return NSAttributedString(string: self.dateFormatter.stringFromDate(date), attributes: attributes as? [String : AnyObject])
  }
  
  func conversationViewController(conversationViewController: ATLConversationViewController, attributedStringForDisplayOfRecipientStatus recipientStatus: [NSObject:AnyObject]) -> NSAttributedString? {
    if (recipientStatus.count == 0) {
      return nil
    }
    let mergedStatuses: NSMutableAttributedString = NSMutableAttributedString()
    
    let recipientStatusDict = recipientStatus as NSDictionary
    let allKeys = recipientStatusDict.allKeys as NSArray
    allKeys.enumerateObjectsUsingBlock { participant, _, _ in
      let participantAsString = participant as! String
      if (participantAsString == self.layerClient.authenticatedUserID) {
        return
      }
      
      let checkmark: String = "✔︎"
      var textColor: UIColor = UIColor.lightGrayColor()
      let status: LYRRecipientStatus! = LYRRecipientStatus(rawValue: Int(recipientStatusDict[participantAsString]!.unsignedIntegerValue))
      switch status! {
      case .Sent:
        textColor = UIColor.lightGrayColor()
      case .Delivered:
        textColor = UIColor.orangeColor()
      case .Read:
        textColor = UIColor.greenColor()
      default:
        textColor = UIColor.lightGrayColor()
      }
      let statusString: NSAttributedString = NSAttributedString(string: checkmark, attributes: [NSForegroundColorAttributeName: textColor])
      mergedStatuses.appendAttributedString(statusString)
    }
    return mergedStatuses;
  }

}

// MARK: - ATLParticipantTableViewController Delegate Methods
extension AMRMessagesDetailsViewController: ATLParticipantTableViewControllerDelegate {
  func participantTableViewController(participantTableViewController: ATLParticipantTableViewController, didSelectParticipant participant: ATLParticipant) {
    print("participant: \(participant)")
    self.addressBarController.selectParticipant(participant)
    print("selectedParticipants: \(self.addressBarController.selectedParticipants)")
    self.navigationController!.dismissViewControllerAnimated(true, completion: nil)
  }
  
  func participantTableViewController(participantTableViewController: ATLParticipantTableViewController, didSearchWithString searchText: String, completion: ((Set<NSObject>!) -> Void)?) {
    AMRUserManager.sharedManager.queryForUserWithName(searchText) { (participants, error) in
      if (error == nil) {
        if let callback = completion {
          callback(NSSet(array: participants as! [AnyObject]) as Set<NSObject>)
        }
      } else {
        print("Error search for participants: \(error)")
      }
    }
  }
}
