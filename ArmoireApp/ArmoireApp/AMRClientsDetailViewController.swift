//
//  AMRClientsDetailViewController.swift
//  ArmoireApp
//
//  Created by Morgan Wildermuth on 10/18/15.
//  Copyright © 2015 Armoire. All rights reserved.
//

import UIKit
//import LayerKit

class AMRClientsDetailViewController: UIViewController, AMRViewControllerProtocol {
  
  var stylist: AMRUser?
  var client: AMRUser?
  var vcArray: [UINavigationController]!
  var selectedViewController: UIViewController?
//  var layerClient: LYRClient!
  @IBOutlet weak var containerView: UIView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setUpNavBar()
    self.title = (client?.firstName)! + " " + (client?.lastName)!
    setVcData(self.stylist, client: self.client)
    selectViewController(vcArray[4])
    // Do any additional setup after loading the view.
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }

  func exitModal(){
    self.dismissViewControllerAnimated(true, completion: nil)
  }

  internal func setVcData(stylist: AMRUser?, client: AMRUser?) {
    self.stylist = stylist
    self.client = client
    setVcArray()
    setVcDataForTabs()
  }

  internal func setUpNavBar(){
    if (self.stylist != nil){
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

  internal func onSettingsTap(){
    let settingsVC = AMRSettingsViewController()
    self.presentViewController(settingsVC, animated: true, completion: nil)
  }

  @IBAction func onTapCalendar(sender: UITapGestureRecognizer) {
    selectViewController(vcArray[2])
  }
  @IBAction func onTapProfile(sender: UITapGestureRecognizer) {
    selectViewController(vcArray[4])
  }
  @IBAction func onTapNote(sender: UITapGestureRecognizer) {
    selectViewController(vcArray[1])
  }
  @IBAction func onTapMessaging(sender: UITapGestureRecognizer) {
  }
  
  private func setVcArray(){
    vcArray = [
      UINavigationController(rootViewController: AMRLoginViewController()),
      UINavigationController(rootViewController: AMRNotesViewController()),
      UINavigationController(rootViewController: AMRUpcomingMeetingsViewController()),
      UINavigationController (rootViewController: AMRSettingsViewController()),
      UINavigationController(rootViewController: AMRClientProfileViewController())
//      UINavigationController(rootViewController: AMRMessagesViewController(layerClient: layerClient) )
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
