//
//  AMRAddClientViewController.swift
//  ArmoireApp
//
//  Created by Morgan Wildermuth on 10/25/15.
//  Copyright © 2015 Armoire. All rights reserved.
//

import UIKit
import MessageUI

class AMRAddClientViewController: UIViewController, AMRViewControllerProtocol, MFMailComposeViewControllerDelegate {

  var client: AMRUser?
  var stylist: AMRUser?

  @IBOutlet weak var clientEmailTextField: UITextField!

  @IBOutlet weak var inviteClientButton: UIButton!
  override func viewDidLoad() {
      super.viewDidLoad()

      // Do any additional setup after loading the view.
  }

  override func didReceiveMemoryWarning() {
      super.didReceiveMemoryWarning()
      // Dispose of any resources that can be recreated.
  }

  @IBAction func onTapDismiss(sender: UIButton) {
    self.dismissViewControllerAnimated(true, completion: nil)
  }

  @IBAction func onInviteClientTap(sender: UIButton) {
    let mailComposeViewController = configuredMailComposeViewController()
    if MFMailComposeViewController.canSendMail() {
      self.presentViewController(mailComposeViewController, animated: true, completion: nil)
    } else {
      self.showSendMailErrorAlert()
    }
  }

  func configuredMailComposeViewController() -> MFMailComposeViewController {
    let mailComposerVC = MFMailComposeViewController()
    mailComposerVC.mailComposeDelegate = self

    var client_email = clientEmailTextField.text!
    mailComposerVC.setToRecipients([client_email])
    mailComposerVC.setSubject("Your Personal Stylist Invites You To Armoire")
    mailComposerVC.setMessageBody("You have been invited to use Armoire, a tool to keep track of your communications, meetings, and conversations with your personal stylist. Download Armoire from here and use the password 'testpassword' to sign in. You'll be prompted to change the password before getting access to your Stylist Created profile for security purposes. Welcome!", isHTML: false)

    return mailComposerVC
  }

  func showSendMailErrorAlert() {
    let sendMailErrorAlert = UIAlertView(title: "Could Not Send Email", message: "Your device could not send e-mail.  Please check e-mail configuration and try again.", delegate: self, cancelButtonTitle: "OK")
    sendMailErrorAlert.show()
  }

  // MARK: MFMailComposeViewControllerDelegate

  func mailComposeController(controller: MFMailComposeViewController!, didFinishWithResult result: MFMailComposeResult, error: NSError!) {
    controller.dismissViewControllerAnimated(true, completion: nil)

  }

  internal func setVcData(stylist: AMRUser?, client: AMRUser?) {
    self.stylist = stylist
    self.client = client
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
