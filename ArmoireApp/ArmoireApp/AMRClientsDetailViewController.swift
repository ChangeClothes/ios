//
//  AMRClientsDetailViewController.swift
//  ArmoireApp
//
//  Created by Morgan Wildermuth on 10/18/15.
//  Copyright © 2015 Armoire. All rights reserved.
//

import UIKit

class AMRClientsDetailViewController: UIViewController, AMRViewControllerProtocol {
  
  var stylist: AMRUser?
  var client: AMRUser?
  var selectedViewController: UIViewController?
//  var layerClient: LYRClient!
  var vcArray: [UINavigationController]!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let exitModalButton: UIButton = UIButton()
    exitModalButton.setImage(UIImage(named: "cancel"), forState: .Normal)
    exitModalButton.frame = CGRectMake(0, 0, 30, 30)
    exitModalButton.addTarget(self, action: Selector("exitModal"), forControlEvents: .TouchUpInside)
    
    let rightNavBarButton = UIBarButtonItem(customView: exitModalButton)
    self.navigationItem.rightBarButtonItem = rightNavBarButton
    print(client)
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
    setVcArray()
    setVcDataForTabs()
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
