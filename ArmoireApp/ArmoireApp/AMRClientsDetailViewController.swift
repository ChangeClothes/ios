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
    self.title = (client?.firstName)! + " " + (client?.lastName)!
    setVcData(self.stylist, client: self.client)
    selectViewController(vcArray[4])
    // Do any additional setup after loading the view.
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
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
  @IBAction func onTapDismiss(sender: AnyObject) {
    self.dismissViewControllerAnimated(true, completion: nil)
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
