//
//  AMRSettingsViewController.swift
//  ArmoireApp
//
//  Created by Morgan Wildermuth on 10/20/15.
//  Copyright © 2015 Armoire. All rights reserved.
//

import UIKit

class AMRSettingsViewController: UIViewController {

  override func viewDidLoad() {
    super.viewDidLoad()
    self.title = "Settings"
    // Do any additional setup after loading the view.
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
    
  @IBAction func onTapDismiss(sender: AnyObject) {
    self.dismissViewControllerAnimated(true, completion: nil)
  }

  @IBAction func onTapLogout(sender: UIButton) {
    PFUser.logOutInBackgroundWithBlock { (error: NSError?) -> Void in
      if let error = error {
        print(error.localizedDescription)
      } else {
        NSNotificationCenter.defaultCenter().postNotificationName(kUserDidLogoutNotification, object: self)
      }
    }
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
