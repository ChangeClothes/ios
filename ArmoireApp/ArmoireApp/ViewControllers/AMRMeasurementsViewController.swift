//
//  MeasurementsViewController.swift
//  ArmoireApp
//
//  Created by Mathew Kellogg on 10/27/15.
//  Copyright © 2015 Armoire. All rights reserved.
//

import UIKit

let measurementCellReuseIdentifier = "com.armoire.AMRMeasurementCell"

class AMRMeasurementsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, AMRViewControllerProtocol, AMRMeasurementCellDelegate {

  @IBOutlet weak var myTableView: UITableView!
  var measurements: [[String: String]] = []
  var stylist: AMRUser?
  var client: AMRUser?
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    
    let cell = tableView.dequeueReusableCellWithIdentifier(measurementCellReuseIdentifier, forIndexPath: indexPath) as! AMRMeasurementCell
    if indexPath.row >= measurements.count {
      cell.key = ""
      cell.value = ""
      cell.isLast = true
    } else {
      print("here")
      let measurement = measurements[indexPath.row]
      cell.key = measurement.keys.first!
      cell.value = measurement.values.first!
      print(measurement)
    }
    cell.delegate = self

    return cell
  }
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return self.measurements.count + 1
  }
  
  func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
    myTableView.deselectRowAtIndexPath(indexPath, animated: true)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    let cellNib = UINib(nibName: "AMRMeasurementCell", bundle: nil)
    myTableView.registerNib(cellNib, forCellReuseIdentifier: measurementCellReuseIdentifier)
    self.navigationController?.setNavigationBarHidden(true, animated: false)
    if let measurements = client?.measurements {
      self.measurements = measurements
    }
    self.myTableView.delegate = self
    self.myTableView.dataSource = self
    
  }
  
  func updateCell(cell: AMRMeasurementCell) {
    let indexPath = myTableView.indexPathForCell(cell)!
    self.measurements[indexPath.row] = [cell.key:cell.value]
    self.client?.measurements = self.measurements
    print(self.measurements)
    self.client!.saveInBackgroundWithBlock { (success, error) -> Void in
      
      print(success)
      print(error)
    }
  }
  
  func removeCell(cell: AMRMeasurementCell) {
    let indexPath = myTableView.indexPathForCell(cell)!
    myTableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
  }
  
  
  func tableView(tableView: UITableView!, canEditRowAtIndexPath indexPath: NSIndexPath!) -> Bool {
    if indexPath.row >= self.measurements.count {
      return false
    } else {
      return true
    }
  }
  
  func tableView(tableView: UITableView!, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath!) {
    if (editingStyle == UITableViewCellEditingStyle.Delete) {
      self.measurements.removeAtIndex(indexPath.row)
      myTableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
      
    }
  }
  
  func addCell(cell: AMRMeasurementCell) {
    let indexPath = myTableView.indexPathForCell(cell)!
    let nextIndexPath = NSIndexPath(forRow: indexPath.row + 1, inSection: indexPath.section)
    measurements.append(["":""])
    myTableView.insertRowsAtIndexPaths([nextIndexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
  }
  
  internal func setVcData(stylist: AMRUser?, client: AMRUser?) {
    self.stylist = stylist
    self.client = client
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }

}
