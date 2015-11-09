//
//  MeasurementsViewController.swift
//  ArmoireApp
//
//  Created by Mathew Kellogg on 10/27/15.
//  Copyright © 2015 Armoire. All rights reserved.
//

import UIKit

let measurementCellReuseIdentifier = "com.armoire.AMRMeasurementCell"

class AMRMeasurementsViewController: AMRViewController, UITableViewDelegate, UITableViewDataSource, AMRMeasurementCellDelegate {

  @IBOutlet weak var myTableView: UITableView!
  var measurements: AMRMeasurements?
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    
    let cell = tableView.dequeueReusableCellWithIdentifier(measurementCellReuseIdentifier, forIndexPath: indexPath) as! AMRMeasurementCell
    if indexPath.row >= measurements?.measurements.count {
      cell.key = ""
      cell.value = ""
      cell.isLast = true
    } else {
      let measurement = measurements!.measurements[indexPath.row]
      cell.key = measurement.keys.first!
      cell.value = measurement.values.first!
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
    AMRMeasurements.measurementsForUser(self.client?.stylist, client: client) { (object, error) -> Void in
      if let measurements = object {
        self.measurements = measurements
      } else {
        self.measurements = AMRMeasurements()
        self.measurements?.stylist = self.client!.stylist!
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
    
    myTableView.backgroundColor = UIColor.AMRPrimaryBackgroundColor()
    let footerView = UIView(frame: CGRectZero)
    myTableView.tableFooterView = footerView
    
    let tapGR = UITapGestureRecognizer(target: self, action: "dismissKeyboard:")
    view.addGestureRecognizer(tapGR)
  }
  
  func dismissKeyboard(sender: UITapGestureRecognizer) {
    view.endEditing(true)
  }
  
  func updateCell(cell: AMRMeasurementCell) {
    let indexPath = myTableView.indexPathForCell(cell)!
    self.measurements?.measurements[indexPath.row] = [cell.key:cell.value]
    self.measurements!.saveInBackground()
    
  }
  
  func removeCell(cell: AMRMeasurementCell) {
    let indexPath = myTableView.indexPathForCell(cell)!
    myTableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
    self.measurements?.measurements.removeAtIndex(indexPath.row)
    self.measurements?.saveInBackground()
  }
  
  
  func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
    if indexPath.row >= self.measurements?.measurements.count {
      return false
    } else {
      return true
    }
  }
  
  func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
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
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }

}
