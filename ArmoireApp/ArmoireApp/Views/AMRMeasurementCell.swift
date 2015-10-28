//
//  MeasurementCell.swift
//  ArmoireApp
//
//  Created by Mathew Kellogg on 10/27/15.
//  Copyright © 2015 Armoire. All rights reserved.
//

import UIKit

class AMRMeasurementCell: UITableViewCell {
  var delegate: AMRMeasurementCellDelegate?

  @IBOutlet weak var valueField: UITextField!
  @IBOutlet weak var keyField: UITextField!
  
  @IBAction func keyEditingDidBegin(sender: UITextField) {
    if self.isLast {
      self.delegate?.addCell(self)
      self.isLast = false
    }
  }
  @IBAction func valueEditingDidBegin(sender: UITextField) {
    if self.isLast {
      self.delegate?.addCell(self)
      self.isLast = false
    }
  }
  @IBAction func keyEditingDidEnd(sender: UITextField) {
    if valueField.text! + keyField.text! == "" {
      //self.delegate?.removeCell(self)
    } else {
      self.delegate?.updateCell(self)
    }
  }
  @IBAction func valueEditingDidEnd(sender: UITextField) {
    if valueField.text! + keyField.text! == "" {
      //self.delegate?.removeCell(self)
    } else {
      self.delegate?.updateCell(self)
    }
  }
  
  var isLast = false
  
  var key: String {
    set(str){
        keyField.text = str
      }
    get {
      return keyField.text!
    }
  }

  var value: String {
    set (str) {
      valueField.text = str
    }
    get {
      return valueField.text!
    }
  }

  override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code

  }
  
  override func setSelected(selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    
  }
  
}

protocol AMRMeasurementCellDelegate {
  func updateCell(cell: AMRMeasurementCell)
  
  func addCell(cell: AMRMeasurementCell)
  
  func removeCell(cell: AMRMeasurementCell)
}
