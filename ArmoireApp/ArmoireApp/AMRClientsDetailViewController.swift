//
//  AMRClientsDetailViewController.swift
//  ArmoireApp
//
//  Created by Morgan Wildermuth on 10/18/15.
//  Copyright © 2015 Armoire. All rights reserved.
//

import UIKit
import LayerKit

class AMRClientsDetailViewController: AMRViewController, AMRViewControllerProtocol,  LYRQueryControllerDelegate  {
  
  var vcArray: [UINavigationController]!
  var selectedViewController: UIViewController?
  var layerClient: LYRClient!
  var selectedIconImageView: UIImageView!
  
  private var queryController: LYRQueryController!
  @IBOutlet weak var containerView: UIView!
  @IBOutlet weak var menuView: UIView!
  
  @IBOutlet weak var notesIconImageView: UIImageView!
  @IBOutlet weak var profileIconImageView: UIImageView!
  @IBOutlet weak var calendarIconImageView: UIImageView!
  @IBOutlet weak var messagesIconImageView: UIImageView!
  
  @IBOutlet weak var selectedIconView: UIView!
  @IBOutlet weak var selectedIconViewXPositionConstraint: NSLayoutConstraint!
  
  @IBOutlet weak var clientProfileImageView: UIImageView!
  
  convenience init(layerClient: LYRClient) {
    self.init()
    self.layerClient = layerClient
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.navigationController?.navigationBarHidden = true
    setVcData(self.stylist, client: self.client)
    
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "deviceDidRotate", name: UIDeviceOrientationDidChangeNotification, object: nil)
    
    setupTabBarAppearance()
    selectViewController(vcArray[3])
    selectedIconImageView = profileIconImageView
    
  }
  
  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
    setSelectedAppearanceColorForImageView(selectedIconImageView)
  }
  
  // MARK: - Appearance Methods
  private func setupTabBarAppearance() {
    messagesIconImageView.image = messagesIconImageView.image?.imageWithRenderingMode(.AlwaysTemplate)
    notesIconImageView.image = notesIconImageView.image?.imageWithRenderingMode(.AlwaysTemplate)
    calendarIconImageView.image = calendarIconImageView.image?.imageWithRenderingMode(.AlwaysTemplate)
    profileIconImageView.image = profileIconImageView.image?.imageWithRenderingMode(.AlwaysTemplate)
    
    resetIconColors()
    
    selectedIconViewXPositionConstraint.constant = -100
    selectedIconView.layer.cornerRadius = 3.0
    selectedIconView.backgroundColor = UIColor.AMRPrimaryBackgroundColor()
    
    menuView.backgroundColor = UIColor.AMRSecondaryBackgroundColor()
    
    if let _ = stylist {
      clientProfileImageView.setAMRImage(client?.profilePhoto, withPlaceholder: "profile-image-placeholder")
    } else {
      clientProfileImageView.setAMRImage(stylist?.profilePhoto, withPlaceholder: "profile-image-placeholder")
    }
    
    clientProfileImageView.image = clientProfileImageView.image?.imageWithRenderingMode(.AlwaysTemplate)
    clientProfileImageView.backgroundColor = UIColor.AMRPrimaryBackgroundColor()
    clientProfileImageView.tintColor = UIColor.lightGrayColor()
    clientProfileImageView.clipsToBounds = true
    clientProfileImageView.layer.cornerRadius = clientProfileImageView.frame.width/2
  }
  
  private func resetIconColors() {
    messagesIconImageView.tintColor = UIColor.AMRClientUnselectedTabBarButtonTintColor()
    notesIconImageView.tintColor = UIColor.AMRClientUnselectedTabBarButtonTintColor()
    calendarIconImageView.tintColor = UIColor.AMRClientUnselectedTabBarButtonTintColor()
    profileIconImageView.tintColor = UIColor.AMRClientUnselectedTabBarButtonTintColor()
  }
  
  private func setSelectedAppearanceColorForImageView(imageView: UIImageView) {
    selectedIconImageView = imageView
    UIView.animateWithDuration(0.5) { () -> Void in
      self.resetIconColors()
      self.selectedIconViewXPositionConstraint.constant = imageView.center.x - self.selectedIconImageView.frame.width/2
      self.view.layoutIfNeeded()
      imageView.tintColor = UIColor.AMRSelectedTabBarButtonTintColor()
    }
  }
  
  func deviceDidRotate() {
    if let selectedIconImageView = selectedIconImageView {
      dispatch_async(dispatch_get_main_queue(), { () -> Void in
        self.selectedIconViewXPositionConstraint.constant = selectedIconImageView.center.x - self.selectedIconView.frame.width/2
      })
    }
  }
  
  // MARK: - View Controller Selection
  func setVcData(stylist: AMRUser?, client: AMRUser?) {
    self.stylist = stylist
    self.client = client
    setVcArray()
    setVcDataForTabs()
  }
  
  private func onSettingsTap(){
    showSettings()
  }
  
  @IBAction func onTapCalendar(sender: UITapGestureRecognizer) {
    selectViewController(vcArray[2])
    setSelectedAppearanceColorForImageView(sender.view as! UIImageView)
  }
  @IBAction func onTapProfile(sender: UITapGestureRecognizer) {
    selectViewController(vcArray[3])
    setSelectedAppearanceColorForImageView(sender.view as! UIImageView)
  }
  @IBAction func onTapNote(sender: UITapGestureRecognizer) {
    selectViewController(vcArray[1])
    setSelectedAppearanceColorForImageView(sender.view as! UIImageView)
  }
  @IBAction func onTapMessaging(sender: UITapGestureRecognizer) {
    filterByClient()
  }
  
  // MARK: - Set Up
  
  private func setVcArray(){
    vcArray = [
      UINavigationController(rootViewController: AMRLoginViewController()),
      UINavigationController(rootViewController: AMRNotesViewController()),
      UINavigationController(rootViewController: AMRUpcomingMeetingsViewController()),
      UINavigationController(rootViewController: AMRClientProfileViewController()),
      UINavigationController(rootViewController: AMRMessagesViewController(layerClient: layerClient) ),
      UINavigationController(rootViewController: AMRMessagesDetailsViewController(layerClient: layerClient))
    ]
  }
  
  private func setVcDataForTabs(){
    for (index, value) in vcArray.enumerate() {
      if (index != 0) {
        let vc = value.viewControllers.first as? AMRViewControllerProtocol
        vc?.setVcData(self.stylist, client: self.client)
      }
    }
  }
  
  private func filterByClient(){
    let participants = [layerClient.authenticatedUserID, client!.objectId, client!.stylist.objectId]
    let query = LYRQuery(queryableClass: LYRConversation.self)
    query.predicate = LYRPredicate(property: "participants", predicateOperator: LYRPredicateOperator.IsEqualTo, value: participants)
    layerClient.executeQuery(query) { (conversations, error) -> Void in
      if let error = error {
        NSLog("Query failed with error %@", error)
      } else if conversations.count <= 1 {
        let nc = UINavigationController(rootViewController: AMRMessagesDetailsViewController(layerClient: self.layerClient))
        let vc = nc.viewControllers.first as! AMRMessagesDetailsViewController
        vc.stylist = self.stylist
        vc.client = self.client
        let conversation = self.retrieveConversation(conversations, participants: participants)
        if let conversation = conversation {
          let shouldShowAddressBar: Bool  = conversation.participants.count > 2 || conversation.participants.count == 0
          vc.displaysAddressBar = shouldShowAddressBar
          vc.conversation = conversation
          self.presentViewController(nc, animated: true, completion: nil)
        } else {
          print("error occurred in transitioning to conversation detail, conversation nil")
        }
      } else {
        NSLog("%tu conversations with participants %@", conversations.count, participants)
      }
    }
  }
  
  private func retrieveConversation(conversations: NSOrderedSet, participants: [AnyObject]) -> LYRConversation? {
    var conversation: LYRConversation?
    if conversations.count == 1 {
      conversation = conversations[0] as? LYRConversation
    } else if conversations.count == 0{
      do {
        conversation = try self.layerClient.newConversationWithParticipants(NSSet(array: participants) as Set<NSObject>, options: nil)
        print("new conversation created since none existed")
      } catch let error {
        print("no conversations; conversation not created. error: \(error)")
      }
    }
    return conversation
  }
  
  // MARK - Functionality
  
  func selectViewController(viewController: UIViewController){
    if let oldViewController = selectedViewController{
      oldViewController.willMoveToParentViewController(nil)
      oldViewController.view.removeFromSuperview()
      oldViewController.removeFromParentViewController()
    }
    
    self.addChildViewController(viewController)
    viewController.view.frame = self.containerView.bounds
    viewController.view.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
    self.containerView.addSubview(viewController.view)
    viewController.didMoveToParentViewController(self)
    selectedViewController = viewController
  }
  
  deinit {
    NSNotificationCenter.defaultCenter().removeObserver(self)
  }
  
}
