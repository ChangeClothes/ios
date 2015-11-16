//
//  AMRTodayTableViewCell.swift
//  ArmoireApp
//
//  Created by Randy Ting on 11/14/15.
//  Copyright © 2015 Armoire. All rights reserved.
//

import UIKit

class AMRTodayTableViewCell: UITableViewCell {
  
  let labelHeight = CGFloat(16)
  let iconHeight = CGFloat(12)
  
  @IBOutlet weak var cellBackgroundView: UIView!
  @IBOutlet weak var appointmentIconView: UIImageView!
  @IBOutlet weak var appointmentIconHeightConstraint: NSLayoutConstraint!
  @IBOutlet weak var newMessageIconView: UIImageView!
  @IBOutlet weak var newMessageIconHeightConstraint: NSLayoutConstraint!
  @IBOutlet weak var unratedPhotoIconView: UIImageView!
  @IBOutlet weak var unratedPhotoIconHeightConstraint: NSLayoutConstraint!
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
      appointmentIconHeightConstraint.constant = 0
      
      newMessagesLabelHeightConstraint.constant = 0
      newMessageIconHeightConstraint.constant = 0
      
      unratedPhotosHeightConstraint.constant = 0
      unratedPhotoIconHeightConstraint.constant = 0
      
      appointmentIconView.tintColor = ThemeManager.currentTheme().highlightColor
      newMessageIconView.tintColor = ThemeManager.currentTheme().highlightColor
      unratedPhotoIconView.tintColor = ThemeManager.currentTheme().highlightColor
      
      
      
      
      if badges?.hasMeetingToday == true {
        appointmentsLabelHeightConstraint.constant = labelHeight
        appointmentIconHeightConstraint.constant = iconHeight
      }
      if badges?.hasUnreadMessages == true {
        newMessagesLabelHeightConstraint.constant = labelHeight
        newMessageIconHeightConstraint.constant = iconHeight
      }
      if badges?.hasUnratedPhotos == true {
        unratedPhotosHeightConstraint.constant = labelHeight
        unratedPhotoIconHeightConstraint.constant = iconHeight
      }
      
      
    }
  }
  
  override func awakeFromNib() {
    super.awakeFromNib()
    cellBackgroundView.backgroundColor = ThemeManager.currentTheme().todayViewCellBackgroundColor
    cellBackgroundView.layer.cornerRadius = 8.0
    cellBackgroundView.clipsToBounds = true
    cellBackgroundView.layer.borderColor = ThemeManager.currentTheme().highlightColor.CGColor
    cellBackgroundView.layer.borderWidth = 1.0
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
