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
  @IBOutlet weak var profileImageView: UIImageView!
  @IBOutlet weak var containerView: UIView!
  
  var selectedViewController: UIViewController?
  var layerClient: LYRClient!
  var stylist: AMRUser?
  var client: AMRUser?
  var vcArray: [UINavigationController]!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "onUserLogin:", name: kUserDidLoginNotification, object: nil)
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "onUserLogout:", name: kUserDidLogoutNotification, object: nil)
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  func onTapSettings(notification: NSNotification){
    let settingsVC = AMRSettingsViewController()
    self.presentViewController(settingsVC, animated: true, completion: nil)
  }
  
  func onUserLogin(notification: NSNotification){
    setVcData(nil, client: nil)
    if (self.client != nil) {
      //client workflow
      selectViewController(vcArray[6])
    } else {
      //stylist workflow
      selectViewController(vcArray[1])
    }
  }
  
  func onUserLogout(notification: NSNotification){
    flushVcArray()
    self.dismissViewControllerAnimated(true, completion: nil)
  }
  
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
      UINavigationController(rootViewController: AMRClientsViewController()),
      UINavigationController(rootViewController: AMRMessagesViewController(layerClient: layerClient) ),
      UINavigationController(rootViewController: AMRNotesViewController()),
      UINavigationController(rootViewController: AMRUpcomingMeetingsViewController()),
      UINavigationController (rootViewController: AMRSettingsViewController()),
      UINavigationController (rootViewController: AMRClientsDetailViewController())
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
        let client_stylist = user["stylist"] as? AMRUser
        client_stylist?.fetchInBackgroundWithBlock({ (loaded_client_stylist, error) -> Void in
          if let error = error {
            print(error.localizedDescription)
          } else {
            self.stylist = loaded_client_stylist as? AMRUser
          }
        })
      }
    }
  }
  
  @IBAction func onTapMessages(sender: UITapGestureRecognizer) {
    selectViewController(vcArray[2])
  }
  
  @IBAction func onTapNotes(sender: AnyObject) {
    selectViewController(vcArray[3])
  }
  
  @IBAction func onTapProfile(sender: AnyObject) {
  }
  
  @IBAction func onTapProfileIcon(sender: AnyObject) {
    selectViewController(vcArray[1])
  }
  
  @IBAction func onTapCalendar(sender: AnyObject) {
    selectViewController(vcArray[4])
  }
  /*
  // MARK: - Navigation
  
  // In a storyboard-based application, you will often want to do a little preparation before navigation
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
  // Get the new view controller using segue.destinationViewController.
  // Pass the selected object to the new view controller.
  }
  */
  
}

protocol AMRViewControllerProtocol {
  func setVcData(stylist: AMRUser?, client: AMRUser?)
}
