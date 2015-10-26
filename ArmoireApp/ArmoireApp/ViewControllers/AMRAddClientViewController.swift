//
//  AMRAddClientViewController.swift
//  ArmoireApp
//
//  Created by Morgan Wildermuth on 10/25/15.
//  Copyright © 2015 Armoire. All rights reserved.
//

import UIKit

class AMRAddClientViewController: UIViewController, AMRViewControllerProtocol {

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
