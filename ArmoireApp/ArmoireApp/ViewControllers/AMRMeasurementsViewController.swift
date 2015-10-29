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
  var measurements: AMRMeasurements?
  var stylist: AMRUser?
  var client: AMRUser?
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    
    let cell = tableView.dequeueReusableCellWithIdentifier(measurementCellReuseIdentifier, forIndexPath: indexPath) as! AMRMeasurementCell
    if indexPath.row >= measurements?.measurements.count {
      cell.key = ""
      cell.value = ""
      cell.isLast = true
    } else {
      print("here")
      let measurement = measurements!.measurements[indexPath.row]
      cell.key = measurement.keys.first!
      cell.value = measurement.values.first!
      print(measurement)
    }
    cell.delegate = self

    return cell
  }
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if self.measurements == nil {
      return 0
    }
    return self.measurements!.measurements.count + 1
  }
  
  func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
    myTableView.deselectRowAtIndexPath(indexPath, animated: true)
  }
  
  override func viewDidLoad() {
    AMRMeasurements.measurementsForUser(stylist, client: client) { (object, error) -> Void in
      if let measurements = object {
        self.measurements = measurements
      } else {
        self.measurements = AMRMeasurements()
        self.measurements?.stylist = self.stylist!
        self.measurements?.client = self.client!
      }
      self.myTableView.reloadData()
    }
    super.viewDidLoad()
    let cellNib = UINib(nibName: "AMRMeasurementCell", bundle: nil)
    myTableView.registerNib(cellNib, forCellReuseIdentifier: measurementCellReuseIdentifier)
    self.navigationController?.setNavigationBarHidden(true, animated: false)
    self.myTableView.delegate = self
    self.myTableView.dataSource = self
  }
  
  func updateCell(cell: AMRMeasurementCell) {
    let indexPath = myTableView.indexPathForCell(cell)!
    self.measurements?.measurements[indexPath.row] = [cell.key:cell.value]
    print("\(cell.key), \(cell.value)")
    self.measurements!.saveInBackground()
    
  }
  
  func removeCell(cell: AMRMeasurementCell) {
    let indexPath = myTableView.indexPathForCell(cell)!
    myTableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
    self.measurements?.measurements.removeAtIndex(indexPath.row)
    self.measurements?.saveInBackground()
  }
  
  
  func tableView(tableView: UITableView!, canEditRowAtIndexPath indexPath: NSIndexPath!) -> Bool {
    if indexPath.row >= self.measurements?.measurements.count {
      return false
    } else {
      return true
    }
  }
  
  func tableView(tableView: UITableView!, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath!) {
    if (editingStyle == UITableViewCellEditingStyle.Delete) {
      self.measurements?.measurements.removeAtIndex(indexPath.row)
      myTableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
      self.measurements?.saveInBackground()
    }
  }
  
  func addCell(cell: AMRMeasurementCell) {
    let indexPath = myTableView.indexPathForCell(cell)!
    let nextIndexPath = NSIndexPath(forRow: indexPath.row + 1, inSection: indexPath.section)
    measurements?.measurements.append(["":""])
    myTableView.insertRowsAtIndexPaths([nextIndexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
    self.measurements?.saveInBackground()
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
