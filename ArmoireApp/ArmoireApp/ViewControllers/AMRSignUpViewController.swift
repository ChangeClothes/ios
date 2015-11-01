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
  optional func signUpViewController(signUpViewController: AMRSignUpViewController, didSignUpUser: AMRUser)
  optional func signUpViewController(signUpViewController: AMRSignUpViewController, didFailToSignUpWithError: NSError)
  optional func signUpViewControllerDidCancelSignUp(signUpViewController: AMRSignUpViewController)
  
}

class AMRSignUpViewController: UIViewController {
  
  @IBOutlet weak var usernameTextField: UITextField!
  @IBOutlet weak var passwordTextField: UITextField!
  @IBOutlet weak var emailAddressTextField: UITextField!
  @IBOutlet weak var firstNameTextField: UITextField!
  @IBOutlet weak var lastNameTextField: UITextField!
  @IBOutlet weak var signUpButton: UIButton!
  
  weak var delegate: AMRSignUpViewControllerDelegate?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let dismissKBGestRecognizer = UITapGestureRecognizer(target: self, action: "didTapView:")
    view.addGestureRecognizer(dismissKBGestRecognizer)

    setupAppearance()
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
  private func setupAppearance() {
    view.backgroundColor = UIColor.AMRSecondaryBackgroundColor()
    
    signUpButton.layer.cornerRadius = 3.0
    signUpButton.backgroundColor = UIColor.AMRBrightButtonBackgroundColor()
    signUpButton.tintColor = UIColor.AMRBrightButtonTintColor()
  }
  
  func didTapView(sender: UITapGestureRecognizer) {
    view.endEditing(true)
  }
  
  @IBAction func signUpButtonTapped(sender: UIButton) {
    let user = AMRUser()
    user.username = usernameTextField.text
    user.password = passwordTextField.text
    user.email = emailAddressTextField.text
    user.firstName = firstNameTextField.text!
    user.lastName = lastNameTextField.text!
    user.isStylist = true
    
    let info: NSDictionary =
    [
      "username"  : usernameTextField.text!,
      "password"  : passwordTextField.text!,
      "email"     : emailAddressTextField.text!,
      "firstName" : firstNameTextField.text!,
      "lastName"  : lastNameTextField.text!,
      "fullName"  : firstNameTextField.text! + " " + lastNameTextField.text!,
      "isStylist" : user.isStylist
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


