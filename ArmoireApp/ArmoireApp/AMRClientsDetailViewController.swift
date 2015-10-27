//
//  AMRClientsDetailViewController.swift
//  ArmoireApp
//
//  Created by Morgan Wildermuth on 10/18/15.
//  Copyright © 2015 Armoire. All rights reserved.
//

import UIKit

class AMRClientsDetailViewController: UIViewController, AMRViewControllerProtocol {
  
  var stylist: AMRUser?
  var client: AMRUser?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.title = "Client Details"
    // Do any additional setup after loading the view.
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
    

  @IBAction func onTapCalendar(sender: UITapGestureRecognizer) {
  }
  @IBAction func onTapProfile(sender: UITapGestureRecognizer) {
  }
  @IBAction func onTapNote(sender: UITapGestureRecognizer) {
  }
  @IBAction func onTapMessaging(sender: UITapGestureRecognizer) {
  }
  @IBAction func onTapDismiss(sender: AnyObject) {
    self.dismissViewControllerAnimated(true, completion: nil)
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
