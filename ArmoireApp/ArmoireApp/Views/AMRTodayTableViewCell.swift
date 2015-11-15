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
  
  var client: AMRUser! {
    didSet {
      let badges = AMRBadgeManager.sharedInstance.clientBadges[client]
      
      self.avatarImage.layer.cornerRadius = self.avatarImage.frame.width/2
      self.avatarImage.clipsToBounds = true
      self.avatarImage.setProfileImageForClientId(client.objectId!, andClient: client, withPlaceholder: "profile-image-placeholder", withCompletion: nil)
      

      nameLabel.text = client.firstName + " " + client.lastName
      appointmentsLabelHeightConstraint.constant = 0
      newMessagesLabelHeightConstraint.constant = 0
      unratedPhotosHeightConstraint.constant = 0
      
      if badges?.hasMeetingToday == true {
        appointmentsLabelHeightConstraint.constant = 16
      }
      if badges?.hasUnreadMessages == true {
        newMessagesLabelHeightConstraint.constant = 16
      }
      if badges?.hasUnratedPhotos == true {
        unratedPhotosHeightConstraint.constant = 16
      }
      
      
    }
  }
  
  override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
  }
  
  override func setSelected(selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    
    // Configure the view for the selected state
  }
  
  override func prepareForReuse() {
    avatarImage.image = nil
  }
  
  
}
