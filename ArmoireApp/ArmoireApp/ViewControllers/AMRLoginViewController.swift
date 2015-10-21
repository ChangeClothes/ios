//
//  AMRLoginViewController.swift
//  ArmoireApp
//
//  Created by Randy Ting on 10/20/15.
//  Copyright © 2015 Armoire. All rights reserved.
//

import UIKit

class AMRLoginViewController: PFLogInViewController {
  
  var customSignUpViewController: AMRSignUpViewController?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    logInView?.signUpButton?.removeTarget(nil, action: nil, forControlEvents: UIControlEvents.AllEvents)
    logInView?.signUpButton?.addTarget(self, action: "signUpButtonTapped:", forControlEvents: UIControlEvents.TouchUpInside)
  }
  
  func signUpButtonTapped(sender: UIButton) {
    presentViewController(customSignUpViewController!, animated: true, completion: nil)
  }
  
}
