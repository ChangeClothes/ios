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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
