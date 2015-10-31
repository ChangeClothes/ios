//
//  AMRClientProfileViewController.swift
//  ArmoireApp
//
//  Created by Morgan Wildermuth on 10/26/15.
//  Copyright © 2015 Armoire. All rights reserved.
//

import UIKit

class AMRClientProfileViewController: UIViewController, UIAlertViewDelegate, AMRViewControllerProtocol{

  @IBOutlet weak var nameLabel: UILabel!
  @IBOutlet weak var containerView: UIView!
  @IBOutlet weak var measurementImageView: UIImageView!
  @IBOutlet weak var cameraImageView: UIImageView!
  
  /*******************************
   *** AMRViewController LOGIC ***
   ******************************/
  var stylist: AMRUser?
  var client: AMRUser?
  var selectedViewController: UIViewController?
  var vcArray: [UINavigationController]!

  //actions
  @IBAction func cameraTap(sender: UITapGestureRecognizer) {
    selectViewController(vcArray[1])
  }
  
  @IBAction func measurementTap(sender: UITapGestureRecognizer) {
    selectViewController(vcArray[0])
  }
  
  override func viewDidLoad() {
    self.navigationController?.navigationBar.translucent = false
    super.viewDidLoad()
    setVcArray()
    setVcDataForTabs()
    selectViewController(vcArray[0])
    loadProfile()
  }
  func setVcData(stylist: AMRUser?, client: AMRUser?) {
    self.stylist = stylist
    self.client = client
    if (client != nil){
      self.title = (client?.firstName)! + " " + (client?.lastName)!
    }
    setUpNavBar()

  }

  func onSettingsTap(){
    let settingsVC = AMRSettingsViewController()
    self.presentViewController(settingsVC, animated: true, completion: nil)
  }

  internal func setUpNavBar(){
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
  
  private func setVcDataForTabs(){
    for (index, value) in vcArray.enumerate() {
      let vc = value.viewControllers.first as? AMRViewControllerProtocol
      vc?.setVcData(self.stylist, client: self.client)
    }
  }
  
  private func setVcArray(){
    let photoVC = UINavigationController(rootViewController: AMRPhotosViewController())
    let measurementsVC = UINavigationController(rootViewController: AMRMeasurementsViewController())
    vcArray = [measurementsVC, photoVC]
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
  
  func loadProfile(){
    nameLabel.text = client?.fullName ?? ""
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
}

