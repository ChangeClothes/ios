//
//  AMRParticipantTableViewController.swift
//  ArmoireApp
//
//  Created by Randy Ting on 10/24/15.
//  Copyright © 2015 Armoire. All rights reserved.
//

import UIKit

class AMRParticipantTableViewController: ATLParticipantTableViewController {

  // MARK - Lifecycle Methods
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let title = NSLocalizedString("Cancel",  comment: "")
    let cancelItem: UIBarButtonItem = UIBarButtonItem(title: title, style: UIBarButtonItemStyle.Plain, target: self, action: Selector("handleCancelTap"))
    self.navigationItem.leftBarButtonItem = cancelItem
  }
  
  // MARK - Actions
  
  func handleCancelTap() {
    self.navigationController!.dismissViewControllerAnimated(true, completion: nil)
  }
}
