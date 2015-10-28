//
//  AMRUpcomingMeetingsTableViewCell.swift
//  ArmoireApp
//
//  Created by Randy Ting on 10/17/15.
//  Copyright © 2015 Armoire. All rights reserved.
//

import UIKit
import EventKit

class AMRUpcomingMeetingsTableViewCell: UITableViewCell {
  
  @IBOutlet weak var apptTitleTextLabel: UILabel!
  @IBOutlet weak var startTimeTextLabel: UILabel!
  @IBOutlet weak var endTimeTextLabel: UILabel!
  @IBOutlet weak var locationTextLabel: UILabel!
  
  var event: EKEvent! {
    didSet{
      apptTitleTextLabel.text = event.title
      locationTextLabel.text = event.location
      startTimeTextLabel.text = DateFormatters.cellDateFormatter.stringFromDate(event.startDate)
      endTimeTextLabel.text = DateFormatters.cellDateFormatter.stringFromDate(event.endDate)
    }
  }
  
  
  override func awakeFromNib() {
    super.awakeFromNib()
  }
  
  override func setSelected(selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    
    // Configure the view for the selected state
  }

  struct DateFormatters {
    static let cellDateFormatter = DateFormatters.sharedCellDateFormatter()
    
    private static func sharedCellDateFormatter() -> NSDateFormatter {
      let dateFormatter = NSDateFormatter()
      dateFormatter.dateStyle = .NoStyle
      dateFormatter.timeStyle = .ShortStyle
      return dateFormatter
    }
  }
}