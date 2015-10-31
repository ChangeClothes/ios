//
//  AMRClientsDetailViewController.swift
//  ArmoireApp
//
//  Created by Morgan Wildermuth on 10/18/15.
//  Copyright © 2015 Armoire. All rights reserved.
//

import UIKit
import LayerKit

class AMRClientsDetailViewController: UIViewController, AMRViewControllerProtocol,  LYRQueryControllerDelegate  {
  
  var stylist: AMRUser?
  var client: AMRUser?
  var vcArray: [UINavigationController]!
  var selectedViewController: UIViewController?
  var layerClient: LYRClient!
  private var queryController: LYRQueryController!
  @IBOutlet weak var containerView: UIView!
  
  convenience init(layerClient: LYRClient) {
    self.init()
    self.layerClient = layerClient
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    self.navigationController?.navigationBarHidden = true
    setVcData(self.stylist, client: self.client)
    selectViewController(vcArray[4])
    // Do any additional setup after loading the view.
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }

  internal func setVcData(stylist: AMRUser?, client: AMRUser?) {
    self.stylist = stylist
    self.client = client
    setVcArray()
    setVcDataForTabs()
  }

  internal func onSettingsTap(){
    let settingsVC = UIAlertController.AMRSettingsController { (AMRSettingsControllerSetting) -> () in}
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
    filterByClient()
  }
  
  // MARK: - Set Up

  private func setVcArray(){
    vcArray = [
      UINavigationController(rootViewController: AMRLoginViewController()),
      UINavigationController(rootViewController: AMRNotesViewController()),
      UINavigationController(rootViewController: AMRUpcomingMeetingsViewController()),
      UINavigationController (rootViewController: AMRSettingsViewController()),
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
    var conversation: LYRConversation?
    layerClient.executeQuery(query) { (conversations, error) -> Void in
      if let error = error {
        NSLog("Query failed with error %@", error)
      } else if conversations.count <= 1 {
        let nc = self.vcArray[6]
        let vc = nc.viewControllers.first as! AMRMessagesDetailsViewController
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
        if let conversation = conversation {
          let shouldShowAddressBar: Bool  = conversation.participants.count > 2 || conversation.participants.count == 0
          vc.displaysAddressBar = shouldShowAddressBar
          vc.conversation = conversation
          self.selectViewController(nc)
        } else {
          print("error occurred in transitioning to conversation detail, conversation nil")
        }
      } else {
        NSLog("%tu conversations with participants %@", conversations.count, participants)
      }
    }
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
