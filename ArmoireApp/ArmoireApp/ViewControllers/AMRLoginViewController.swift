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
  
  @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
  
  weak var delegate: AMRLoginViewControllerDelegate?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    signUpButton.removeTarget(nil, action: nil, forControlEvents: UIControlEvents.AllEvents)
    signUpButton.addTarget(self, action: "signUpButtonTapped:", forControlEvents: UIControlEvents.TouchUpInside)
    signUpButton.tintColor = ThemeManager.currentTheme().highlightColor
    
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
    
    backgroundImageView.image = UIImage(named: "login-background")
    
    let tapGR = UITapGestureRecognizer(target: self, action: "dismissKeyboard:")
    view.addGestureRecognizer(tapGR)
    
  }
  
  func dismissKeyboard(sender: UITapGestureRecognizer) {
    view.endEditing(true)
    UIView.animateWithDuration(0.5) { () -> Void in
      self.bottomConstraint.constant = 75
      self.view.layoutIfNeeded()
    }
 
  }
  
  func keyboardWillShow(notification: NSNotification){
      let userInfo = notification.userInfo as? NSDictionary
      let endLocationOfKeyboard = userInfo?[UIKeyboardFrameEndUserInfoKey]?.CGRectValue
      let size = endLocationOfKeyboard?.size
      let keyboardHeight = size?.height
      moveNoteUp(keyboardHeight)
  }
  
  override func viewWillAppear(animated: Bool) {
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
  }
  override func viewWillDisappear(animated: Bool){
    super.viewWillDisappear(animated)
    NSNotificationCenter.defaultCenter().removeObserver(self)
  }
  
  
  private func moveNoteUp(keyboardHeight: CGFloat?){
    UIView.animateWithDuration(1) { () -> Void in
      self.bottomConstraint.constant = keyboardHeight! + 10
      self.view.layoutIfNeeded()
    }
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
