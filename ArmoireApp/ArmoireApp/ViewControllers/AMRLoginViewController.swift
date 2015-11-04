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
    logInView?.logInButton?.addTarget(self, action: "loginButtonTapped:", forControlEvents: UIControlEvents.TouchUpInside)
    
    logInView?.dismissButton?.hidden = true
    
    let logoImageView = UIImageView(image: UIImage(named: "Armoire"))
    logoImageView.contentMode = .ScaleAspectFit
    logInView?.logo = logoImageView
    
    logInView?.backgroundColor = UIColor.AMRUnselectedTabBarButtonTintColor()
    
    logInView
  }
  
  func loginButtonTapped(sender: UIButton) {
    logInView?.usernameField?.text = ""
    logInView?.passwordField?.text = ""
  }
  
  func signUpButtonTapped(sender: UIButton) {
    customSignUpViewController?.modalPresentationStyle = .OverCurrentContext
    
    presentViewController(customSignUpViewController!, animated: true, completion: nil)
  }
  
}
