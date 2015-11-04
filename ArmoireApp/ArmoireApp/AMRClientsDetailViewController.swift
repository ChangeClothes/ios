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
  
  @IBOutlet weak var newMessageImageViewContainerYConstraint: NSLayoutConstraint!
  @IBOutlet weak var newMessageImageViewContainerXConstraint: NSLayoutConstraint!
  @IBOutlet weak var newMessageImageViewContainer: UIView!
  @IBOutlet weak var newMessageImageView: UIImageView!
  
  var vcArray: [UINavigationController]!
  var selectedViewController: UIViewController?
  var layerClient: LYRClient!
  var selectedIconImageView: UIImageView!
  var newMessageTapGestureStartPoint: CGFloat!
  var newConversationIdentifier: NSURL!
  
  private var queryController: LYRQueryController!
  var layerQueryController: LYRQueryController!
  
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
    
    setupLayerQueryController()
    setupNewMessageImageView()
  }
  
  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
    setSelectedAppearanceColorForImageView(selectedIconImageView)
  }
  
  private func setupLayerQueryController() {
    let query = LYRQuery(queryableClass: LYRConversation.self)
    query.predicate = LYRPredicate(property: "hasUnreadMessages", predicateOperator: LYRPredicateOperator.IsEqualTo, value: true)
    layerQueryController = try? layerClient.queryControllerWithQuery(query, error: ())
    layerQueryController.delegate = self
    layerQueryController.executeWithCompletion { (success: Bool, error: NSError!) -> Void in
      if let error = error {
        print(error.localizedDescription)
      } else {
        print("Query fetched \(self.layerQueryController.numberOfObjectsInSection(0)) message objects")
      }
    }
  }
  
  private func setupNewMessageImageView() {
    newMessageImageView.image = newMessageImageView.image?.imageWithRenderingMode(.AlwaysTemplate)
    newMessageImageView.clipsToBounds = true
    newMessageImageView.layer.cornerRadius = newMessageImageView.frame.width/2
    newMessageImageView.backgroundColor = UIColor.AMRBrightButtonBackgroundColor()
    
    let newMessagePanGR = UIPanGestureRecognizer(target: self, action: "onMessageIconPan:")
    newMessagePanGR.delegate = self
    newMessageImageView.addGestureRecognizer(newMessagePanGR)
    
    let newMessageTapGR = UITapGestureRecognizer(target: self, action: "onMessageIconTap:")
    newMessageImageView.addGestureRecognizer(newMessageTapGR)
    newMessageTapGestureStartPoint = newMessageImageViewContainerXConstraint.constant
    
    containerView.layer.masksToBounds = false
    newMessageImageViewContainer.layer.masksToBounds = false;
    newMessageImageViewContainer.layer.cornerRadius = newMessageImageViewContainer.frame.width/2
    newMessageImageViewContainer.layer.shadowOffset = CGSizeMake(0, 0);
    newMessageImageViewContainer.layer.shadowRadius = 5;
    newMessageImageViewContainer.layer.shadowOpacity = 0.7;
    newMessageImageViewContainer.clipsToBounds = false

    hideNewMessageImageView()
  }
  
  func onMessageIconTap(sender: UITapGestureRecognizer) {
    presentConversationWithIdentifier(newConversationIdentifier)
  }
  
  private func presentConversationWithIdentifier(identifier: NSURL) {
    let query = LYRQuery(queryableClass: LYRConversation.self)
    query.predicate = LYRPredicate(property: "identifier", predicateOperator: LYRPredicateOperator.IsEqualTo, value: identifier)
    layerClient.executeQuery(query) { (conversations, error) -> Void in
      if let error = error {
        print(error.localizedDescription)
      } else {
        let nc = UINavigationController(rootViewController: AMRMessagesDetailsViewController(layerClient: self.layerClient))
        let vc = nc.viewControllers.first as! AMRMessagesDetailsViewController
        vc.conversation = conversations.firstObject as! LYRConversation
        let dismissButton = UIBarButtonItem(title: "Dismiss", style: .Plain , target: self, action: "dismissModal:")
        vc.navigationItem.leftBarButtonItem = dismissButton
        self.presentViewController(nc, animated: true, completion: nil)
      }
    }
  }
  
  func dismissModal(sender: UIBarButtonItem) {
    dismissViewControllerAnimated(true) { () -> Void in
      self.hideNewMessageImageView()
    }
  }
  
  func onMessageIconPan(sender: UIPanGestureRecognizer) {
    let state = sender.state
    let translation = sender.translationInView(view)
    
    switch (state) {
    case .Began:
      newMessageTapGestureStartPoint = newMessageImageViewContainerXConstraint.constant
    case .Cancelled:
      break
    case .Changed:
      newMessageImageViewContainerXConstraint.constant = newMessageTapGestureStartPoint - translation.x
      newMessageImageView.alpha = 1.0 - ((translation.x * -0.1) / 8)
      newMessageImageViewContainer.alpha = 1.0 - ((translation.x * -0.1) / 8)
    case .Ended:
      if Double(sqrt((translation.x * translation.x) + (translation.y * translation.y) )) > 10.0 {
        hideNewMessageImageView()
      }
    case .Failed:
      break
    case .Possible:
      break
    }
  }
  
  //MARK: - Utility
  func hideNewMessageImageView() {
    UIView.animateWithDuration(1.0, animations: { () -> Void in
      self.newMessageImageView.alpha = 0.0
      self.newMessageImageViewContainer.alpha = 1.0
      }) { (success: Bool) -> Void in
        self.newMessageImageViewContainerXConstraint.constant = self.newMessageTapGestureStartPoint
        self.newMessageImageViewContainerYConstraint.constant = 1000.0
    }
    NSNotificationCenter.defaultCenter().postNotificationName(kNewMessageIconHidden, object: self)
  }
  
  func showNewMessageImageView() {
    containerView.layoutIfNeeded()
    containerView.bringSubviewToFront(newMessageImageViewContainer)
    newMessageImageViewContainerYConstraint.constant = 10
    newMessageImageView.alpha = 1.0
    newMessageImageViewContainer.alpha = 1.0
    UIView.animateWithDuration(0.8, delay: 0.0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.8, options: UIViewAnimationOptions.AllowUserInteraction, animations: { () -> Void in
      self.containerView.layoutIfNeeded()
      }, completion: nil)
    NSNotificationCenter.defaultCenter().postNotificationName(kNewMessageIconShown, object: self)
  }
  
  // MARK: - Appearance Methods
  private func setupTabBarAppearance() {
    messagesIconImageView.image = messagesIconImageView.image?.imageWithRenderingMode(.AlwaysTemplate)
    notesIconImageView.image = notesIconImageView.image?.imageWithRenderingMode(.AlwaysTemplate)
    calendarIconImageView.image = calendarIconImageView.image?.imageWithRenderingMode(.AlwaysTemplate)
    profileIconImageView.image = profileIconImageView.image?.imageWithRenderingMode(.AlwaysTemplate)
    
    resetIconColors()
    
    selectedIconViewXPositionConstraint.constant = -100
    selectedIconView.layer.cornerRadius = selectedIconView.frame.width/2
    selectedIconView.backgroundColor = UIColor.AMRPrimaryBackgroundColor()
    
    menuView.backgroundColor = UIColor.AMRSecondaryBackgroundColor()
    
    
    if let _ = stylist {
      client?.fetchIfNeededInBackgroundWithBlock({ (user, error) -> Void in
        let clientObject = user as! AMRUser
        let photoId = clientObject.profilePhoto?.objectId
        if photoId != nil {
          AMRImage.queryForObjectWithObjectID(clientObject.profilePhoto!.objectId!, withCompletion: { (photos: NSArray?, error: NSError?) -> Void in
            if error == nil {
              self.clientProfileImageView.setAMRImage(photos![0] as? AMRImage, withPlaceholder: "profile-image-placeholder")
            } else {
              print("Error: \(error)")
            }
          })
        }
      })
      //clientProfileImageView.setAMRImage(client?.profilePhoto, withPlaceholder: "profile-image-placeholder")
    } else {
      client?.stylist?.fetchIfNeededInBackgroundWithBlock({ (user: PFObject?, error: NSError?) -> Void in
        self.clientProfileImageView.setAMRImage((user as! AMRUser).profilePhoto, withPlaceholder: "profile-image-placeholder")
      })
      
//      AMRUserManager.sharedManager.queryForUserWithObjectID((client?.stylist!.objectId)!, withCompletion: { (users, error) -> Void in
//        let stylistObject = users![0] as! AMRUser
//        if let stylistProfilePhotoID = stylistObject.profilePhoto?.objectId {
//          AMRImage.queryForObjectWithObjectID(stylistProfilePhotoID, withCompletion: { (photos: NSArray?, error: NSError?) -> Void in
//            self.clientProfileImageView.setAMRImage(photos![0] as! AMRImage, withPlaceholder: "profile-image-placeholder")
//          })
//        }
//      })
    }
    
    clientProfileImageView.image = clientProfileImageView.image?.imageWithRenderingMode(.AlwaysTemplate)
    clientProfileImageView.backgroundColor = UIColor.AMRPrimaryBackgroundColor()
    clientProfileImageView.tintColor = UIColor.AMRClientUnselectedTabBarButtonTintColor()
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
      self.selectedIconViewXPositionConstraint.constant = self.selectedIconImageView.center.x - self.selectedIconView.frame.width/2
      self.menuView.layoutIfNeeded()
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
    if newMessageImageView.alpha == 1.0 {
      showNewMessageImageView()
    }
  }
  @IBAction func onTapProfile(sender: UITapGestureRecognizer) {
    selectViewController(vcArray[3])
    setSelectedAppearanceColorForImageView(sender.view as! UIImageView)
    if newMessageImageView.alpha == 1.0 {
      showNewMessageImageView()
    }
  }
  @IBAction func onTapNote(sender: UITapGestureRecognizer) {
    selectViewController(vcArray[1])
    setSelectedAppearanceColorForImageView(sender.view as! UIImageView)
    if newMessageImageView.alpha == 1.0 {
      showNewMessageImageView()
    }
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
        value.navigationBar.tintColor = UIColor.AMRBrightButtonTintColor()
        value.navigationBar.barTintColor = UIColor.AMRUnselectedTabBarButtonTintColor()
        value.navigationBar.backgroundColor = UIColor.AMRUnselectedTabBarButtonTintColor()
        value.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.AMRBrightButtonTintColor()]
      }
    }
  }
  
  private func filterByClient(){
    let participants = [layerClient.authenticatedUserID, client!.objectId, client!.stylist!.objectId]
    let query = LYRQuery(queryableClass: LYRConversation.self)
    query.predicate = LYRPredicate(property: "participants", predicateOperator: LYRPredicateOperator.IsEqualTo, value: participants)
    layerClient.executeQuery(query) { (conversations, error) -> Void in
      if let error = error {
        NSLog("Query failed with error %@", error)
      } else if conversations.count <= 1 {
        let nc = UINavigationController(rootViewController: AMRMessagesDetailsViewController(layerClient: self.layerClient))
        let vc = nc.viewControllers.first as! AMRMessagesDetailsViewController
        vc.client = self.client
        vc.stylist = self.stylist
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

// MARK: - LYRQueryController Delegate

extension AMRClientsDetailViewController {
  func queryController(controller: LYRQueryController!, didChangeObject object: AnyObject!, atIndexPath indexPath: NSIndexPath!, forChangeType type: LYRQueryControllerChangeType, newIndexPath: NSIndexPath!) {
    if type != LYRQueryControllerChangeType.Delete && controller.numberOfObjectsInSection(0) > 0 {
      let conversation = object as! LYRConversation
      newConversationIdentifier = conversation.identifier
      let senderObjectID = conversation.participants.first as! String
      AMRUserManager.sharedManager.queryForUserWithObjectID(senderObjectID) { (users: NSArray?, error: NSError?) -> Void in
        if let error = error {
          print(error.localizedDescription)
        } else {
          let user = users!.firstObject! as! AMRUser
          if let profileImage = user.profilePhoto {
            self.newMessageImageView.setAMRImage(profileImage, withPlaceholder: "messaging")
          } else {
            self.newMessageImageView.setAMRImage(nil, withPlaceholder: "messaging")
          }
          self.showNewMessageImageView()
        }
        
      }
    }
    
  }
}

// MARK: - UIGestureRecognizer Delegate

extension AMRClientsDetailViewController: UIGestureRecognizerDelegate {
  func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
    return true
  }
}
