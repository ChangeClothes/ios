//
//  AMRTodayTableViewCell.swift
//  ArmoireApp
//
//  Created by Randy Ting on 11/14/15.
//  Copyright © 2015 Armoire. All rights reserved.
//

import UIKit

class AMRTodayTableViewCell: UITableViewCell {

  @IBOutlet weak var avatarImage: UIImageView!
  
  @IBOutlet weak var nameLabel: UILabel!
  @IBOutlet weak var appointmentsLabelHeightConstraint: NSLayoutConstraint!
  
  @IBOutlet weak var newMessagesLabelHeightConstraint: NSLayoutConstraint!
  
  @IBOutlet weak var unratedPhotosHeightConstraint: NSLayoutConstraint!
  
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
