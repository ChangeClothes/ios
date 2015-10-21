//
//  AMRSignUpViewController.swift
//  ArmoireApp
//
//  Created by Randy Ting on 10/20/15.
//  Copyright © 2015 Armoire. All rights reserved.
//

import UIKit


@objc protocol AMRSignUpViewControllerDelegate: class {
  optional func signUpViewController(signUpViewController: AMRSignUpViewController, shouldBeginSignUp: NSDictionary) -> Bool
  optional func signUpViewController(signUpViewController: AMRSignUpViewController, didSignUpUser: PFUser)
  optional func signUpViewController(signUpViewController: AMRSignUpViewController, didFailToSignUpWithError: NSError)
  optional func signUpViewControllerDidCancelSignUp(signUpViewController: AMRSignUpViewController)
  
}

class AMRSignUpViewController: UIViewController {
  
  @IBOutlet weak var usernameTextField: UITextField!
  @IBOutlet weak var passwordTextField: UITextField!
  @IBOutlet weak var emailAddressTextField: UITextField!
  @IBOutlet weak var firstNameTextField: UITextField!
  @IBOutlet weak var lastNameTextField: UITextField!
  @IBOutlet weak var stylistOrClientSegmentedControl: UISegmentedControl!
  
  weak var delegate: AMRSignUpViewControllerDelegate?
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
  @IBAction func signUpButtonTapped(sender: UIButton) {
    let user = PFUser()
    user.username = usernameTextField.text
    user.password = passwordTextField.text
    user.email = emailAddressTextField.text
    user["firstName"] = firstNameTextField.text!
    user["lastName"] = lastNameTextField.text!
    if stylistOrClientSegmentedControl.selectedSegmentIndex == 0 {
      user["isStylist"] = true
    } else {
      user["isStylist"] = false
    }
    
    let info: NSDictionary =
    [
      "username"  : usernameTextField.text!,
      "password"  : passwordTextField.text!,
      "email"     : emailAddressTextField.text!,
      "firstName" : firstNameTextField.text!,
      "lastName"  : lastNameTextField.text!,
      "isStylist" : user["isStylist"]
    ]
    
    guard let shouldBeginSetup = delegate?.signUpViewController?(self, shouldBeginSignUp: info) where shouldBeginSetup == false else {
      user.signUpInBackgroundWithBlock { (success: Bool, error: NSError?) -> Void in
        if let error = error {
          self.delegate?.signUpViewController?(self, didFailToSignUpWithError: error)
        } else {
          self.delegate?.signUpViewController?(self, didSignUpUser: user)
        }
      }
      return
    }
  }

  @IBAction func dimissButtonTapped(sender: UIButton) {
    delegate?.signUpViewControllerDidCancelSignUp?(self)
  }
  
  
}


