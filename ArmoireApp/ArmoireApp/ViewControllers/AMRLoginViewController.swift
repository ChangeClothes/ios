//
//  AMRLoginViewController.swift
//  ArmoireApp
//
//  Created by Randy Ting on 10/20/15.
//  Copyright © 2015 Armoire. All rights reserved.
//

import UIKit

protocol AMRLoginViewControllerDelegate: class{
  func logInViewController(logInController: AMRLoginViewController, didLoginUser user: PFUser)
}

class AMRLoginViewController: UIViewController {
  
  @IBOutlet weak var signUpButton: UIButton!
  @IBOutlet weak var logInButton: UIButton!
  @IBOutlet weak var usernameField: UITextField!
  @IBOutlet weak var passwordField: UITextField!
  @IBOutlet weak var backgroundImageView: UIImageView!
  @IBOutlet weak var logoImageView: UIImageView!
  var customSignUpViewController: AMRSignUpViewController?
  
  weak var delegate: AMRLoginViewControllerDelegate?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    signUpButton.removeTarget(nil, action: nil, forControlEvents: UIControlEvents.AllEvents)
    signUpButton.addTarget(self, action: "signUpButtonTapped:", forControlEvents: UIControlEvents.TouchUpInside)
    signUpButton.tintColor = ThemeManager.currentTheme().mainColorSecondary
    
    logInButton?.addTarget(self, action: "loginButtonTapped:", forControlEvents: UIControlEvents.TouchUpInside)
    logInButton.layer.cornerRadius = 6.0
    logInButton.backgroundColor = ThemeManager.currentTheme().mainColorSecondary

    logoImageView.contentMode = .ScaleAspectFit
    logoImageView.image = UIImage(named: "Armoire")
    
    usernameField.borderStyle = .RoundedRect
    usernameField.backgroundColor = UIColor(colorLiteralRed: 1.0, green: 1.0, blue: 1.0, alpha: 0.7)
    usernameField.textColor = UIColor(colorLiteralRed: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
    passwordField.borderStyle = .RoundedRect
    passwordField.backgroundColor = UIColor(colorLiteralRed: 1.0, green: 1.0, blue: 1.0, alpha: 0.7)
    passwordField.textColor = UIColor(colorLiteralRed: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
    
    backgroundImageView.image = UIImage.sd_animatedGIFNamed("Armoire_LoginPageBackground")
    
    let tapGR = UITapGestureRecognizer(target: self, action: "dismissKeyboard:")
    view.addGestureRecognizer(tapGR)
    
  }
  
  func dismissKeyboard(sender: UITapGestureRecognizer) {
    view.endEditing(true)
  }
  
  func loginButtonTapped(sender: UIButton) {
    PFUser.logInWithUsernameInBackground(usernameField.text!, password: passwordField.text!) { (user: PFUser?, error: NSError?) -> Void in
      if let error = error {
        print(error.localizedDescription)
      } else {
        self.delegate?.logInViewController(self, didLoginUser: user!)
      }
    }
    
    usernameField.text = ""
    passwordField.text = ""
  }
  
  func signUpButtonTapped(sender: UIButton) {
    customSignUpViewController?.modalPresentationStyle = .OverCurrentContext
    
    presentViewController(customSignUpViewController!, animated: true, completion: nil)
  }
  
}
