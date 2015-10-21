//
//  AMRMainViewController.swift
//  ArmoireApp
//
//  Created by Randy Ting on 10/17/15.
//  Copyright © 2015 Armoire. All rights reserved.
//

import UIKit

class AMRMainViewController: UIViewController {
  
  @IBOutlet weak var menuView: UIView!
  @IBOutlet weak var messagesImageView: UIImageView!
  @IBOutlet weak var notesImageView: UIImageView!
  @IBOutlet weak var calendarImageView: UIImageView!
  @IBOutlet weak var profileIconImageView: UIImageView!
  @IBOutlet weak var profileImageView: UIImageView!
  @IBOutlet weak var containerView: UIView!
  var selectedViewController: UIViewController?
  let vcArray = [
    UINavigationController(rootViewController: AMRLoginViewController()),
    UINavigationController(rootViewController: AMRClientsViewController()),
    UINavigationController(rootViewController: AMRMessagesViewController()),
    UINavigationController(rootViewController: AMRNotesViewController()),
    UINavigationController(rootViewController: AMRUpcomingMeetingsViewController()),
    UINavigationController(rootViewController: AMRClientsViewController()),
    UINavigationController (rootViewController: AMRSettingsViewController())
  ]
  
  override func viewDidLoad() {
    super.viewDidLoad()
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "onUserLogin:", name: "userDidLoginNotification", object: nil)
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "onTapSettings:", name: "userDidTapSettingsNotification", object: nil)
    selectViewController(vcArray[1])
    let testObject = PFObject(className: "TestObject")
    testObject["foo"] = "bar"
    testObject.saveInBackgroundWithBlock { (success: Bool, error: NSError?) -> Void in
      print("Object has been saved.")
    }
  }
    
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }

    
  func onTapSettings(notification: NSNotification){
    selectViewController(vcArray[6])
  }
  
  func onUserLogin(notification: NSNotification){
    selectViewController(vcArray[1])
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
  
  
  @IBAction func onTapMessages(sender: UITapGestureRecognizer) {
    selectViewController(vcArray[2])
  }

  @IBAction func onTapNotes(sender: AnyObject) {
    selectViewController(vcArray[3])
  }
    
  @IBAction func onTapProfile(sender: AnyObject) {
    PFUser.logOutInBackgroundWithBlock { (error: NSError?) -> Void in
      if let error = error {
        print(error.localizedDescription)
      } else {
        NSNotificationCenter.defaultCenter().postNotificationName(kUserDidLogoutNotification, object: self)
      }
    }
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
