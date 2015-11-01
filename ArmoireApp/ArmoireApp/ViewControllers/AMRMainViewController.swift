//
//  AMRMainViewController.swift
//  ArmoireApp
//
//  Created by Randy Ting on 10/17/15.
//  Copyright © 2015 Armoire. All rights reserved.
//

import UIKit
import LayerKit

class AMRMainViewController: UIViewController, AMRViewControllerProtocol {
  
  @IBOutlet weak var menuView: UIView!
  @IBOutlet weak var messagesImageView: UIImageView!
  @IBOutlet weak var notesImageView: UIImageView!
  @IBOutlet weak var calendarImageView: UIImageView!
  @IBOutlet weak var profileIconImageView: UIImageView!
  @IBOutlet weak var containerView: UIView!
  @IBOutlet weak var selectedIconView: UIView!
  
  @IBOutlet weak var selectedIconViewXPositionConstraint: NSLayoutConstraint!
  
  var selectedViewController: UIViewController?
  var layerClient: LYRClient!
  var stylist: AMRUser?
  var client: AMRUser?
  var vcArray: [UINavigationController]!
  var selectedIconImageView: UIImageView?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "onShowMenuView:", name: AMRMainShowMenuView, object: nil)
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "onHideMenuView:", name: AMRMainHideMenuView, object: nil)
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "onUserLogin:", name: kUserDidLoginNotification, object: nil)
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "onUserLogout:", name: kUserDidLogoutNotification, object: nil)
    
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "deviceDidRotate", name: UIDeviceOrientationDidChangeNotification, object: nil)
   setupTabBarAppearance()
  
  }
  
  // MARK: - Appearance Methods
  private func setupTabBarAppearance() {
    messagesImageView.image = messagesImageView.image?.imageWithRenderingMode(.AlwaysTemplate)
    notesImageView.image = notesImageView.image?.imageWithRenderingMode(.AlwaysTemplate)
    calendarImageView.image = calendarImageView.image?.imageWithRenderingMode(.AlwaysTemplate)
    profileIconImageView.image = profileIconImageView.image?.imageWithRenderingMode(.AlwaysTemplate)
    
    resetIconColors()
    
    selectedIconView.layer.cornerRadius = 3.0
    selectedIconView.backgroundColor = UIColor.AMRSecondaryBackgroundColor()
    print(profileIconImageView.center.x)
    
    selectedIconViewXPositionConstraint.constant = 1000
    view.layoutIfNeeded()
    
    menuView.backgroundColor = UIColor.AMRPrimaryBackgroundColor() 
  }
  
  private func resetIconColors() {
    messagesImageView.tintColor = UIColor.AMRUnselectedTabBarButtonTintColor()
    notesImageView.tintColor = UIColor.AMRUnselectedTabBarButtonTintColor()
    calendarImageView.tintColor = UIColor.AMRUnselectedTabBarButtonTintColor()
    profileIconImageView.tintColor = UIColor.AMRUnselectedTabBarButtonTintColor()
  }
  
  private func setSelectedAppearanceColorForImageView(imageView: UIImageView) {
    selectedIconImageView = imageView
    
    UIView.animateWithDuration(0.5) { () -> Void in
      self.resetIconColors()
      self.selectedIconViewXPositionConstraint.constant = imageView.center.x - self.selectedIconView.frame.width/2
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

  func onShowMenuView(notification: NSNotification) {
    menuView.hidden = false
  }

  func onHideMenuView(notification: NSNotification) {
    menuView.hidden = true
  }

  // MARK: - Settings Icon
  func onTapSettings(notification: NSNotification){
    let settingsVC = AMRSettingsViewController()
    self.presentViewController(settingsVC, animated: true, completion: nil)
  }
  
  // MARK: - Notifiation Observers
  func onUserLogin(notification: NSNotification){
    setVcData(nil, client: nil)
    if (self.client != nil) {
      //client workflow
      let vc = AMRClientsDetailViewController(layerClient: layerClient)
      vc.setVcData(self.stylist, client: self.client)
      UIApplication.sharedApplication().windows[0].rootViewController = vc
      UIApplication.sharedApplication().windows[0].makeKeyAndVisible()
    } else {
      //stylist workflow
      selectViewController(vcArray[1])
      setSelectedAppearanceColorForImageView(profileIconImageView)
    }
  }
  
  func onUserLogout(notification: NSNotification){
    self.client = nil
    self.stylist = nil
    flushVcArray()
    self.dismissViewControllerAnimated(true, completion: nil)
  }
  
  // MARK: - View Controller Selection
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
  
  internal func flushVcArray() {
    vcArray = nil
  }
  
  internal func setVcData(stylist: AMRUser?, client: AMRUser?) {
    setVcArray()
    setLocalVcData()
    setVcDataForTabs()
  }
  
  private func setVcArray(){
    vcArray = [
      UINavigationController(rootViewController: AMRLoginViewController()),
      UINavigationController(rootViewController: AMRClientsViewController(layerClient: layerClient)),
      UINavigationController(rootViewController: AMRMessagesViewController(layerClient: layerClient) ),
      UINavigationController(rootViewController: AMRNotesViewController()),
      UINavigationController(rootViewController: AMRUpcomingMeetingsViewController()),
      UINavigationController (rootViewController: AMRSettingsViewController()),
      UINavigationController (rootViewController: AMRClientsDetailViewController(layerClient: layerClient))
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

  private func setLocalVcData(){
    if let user = AMRUser.currentUser(){
      if (user.isStylist){
        self.stylist = user
      } else {
        self.client = user
      }
    }
  }
  
  // MARK: - Tap Icon Actions
  
  @IBAction func onTapMessages(sender: UITapGestureRecognizer) {
    selectViewController(vcArray[2])
    setSelectedAppearanceColorForImageView(sender.view as! UIImageView)
  }
  
  @IBAction func onTapNotes(sender: UITapGestureRecognizer) {
    selectViewController(vcArray[3])
    setSelectedAppearanceColorForImageView(sender.view as! UIImageView)
  }
  
  @IBAction func onTapProfile(sender: UITapGestureRecognizer) {
  }
  
  @IBAction func onTapProfileIcon(sender: UITapGestureRecognizer) {
    selectViewController(vcArray[1])
    setSelectedAppearanceColorForImageView(sender.view as! UIImageView)
  }
  
  @IBAction func onTapCalendar(sender: UITapGestureRecognizer) {
    selectViewController(vcArray[4])
    setSelectedAppearanceColorForImageView(sender.view as! UIImageView)
  }
  
}

protocol AMRViewControllerProtocol {
  func setVcData(stylist: AMRUser?, client: AMRUser?)
}
