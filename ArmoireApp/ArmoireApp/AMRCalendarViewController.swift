//
//  AMRCalendarViewController.swift
//  ArmoireApp
//
//  Created by Morgan Wildermuth on 10/18/15.
//  Copyright © 2015 Armoire. All rights reserved.
//

import UIKit

class AMRCalendarViewController: UIViewController {

    @IBOutlet weak var appointmentTable: UITableView!
    var appointments: NSDictionary?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Appointments"

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = appointmentTable.dequeueReusableCellWithIdentifier("AppointmentCell", forIndexPath: indexPath) as! AMRAppointmentTableViewCell
    return cell
  }
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if let appointmentList = self.appointments {
      return appointmentList.count
    } else {
      return 0
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
