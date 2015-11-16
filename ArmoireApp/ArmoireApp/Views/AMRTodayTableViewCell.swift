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
  
  @IBOutlet weak var appointmentIconHeightConstraint: NSLayoutConstraint!
  @IBOutlet weak var cellBackgroundView: UIView!
  @IBOutlet weak var appointmentIconView: UIImageView!
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
      
      appointmentIconView.tintColor = UIColor.darkGrayColor()
      newMessageIconView.tintColor = UIColor.darkGrayColor()
      unratedPhotoIconView.tintColor = UIColor.darkGrayColor()
      
      appointmentIconView.image = appointmentIconView.image?.imageWithRenderingMode(.AlwaysTemplate)
      newMessageIconView.image = newMessageIconView.image?.imageWithRenderingMode(.AlwaysTemplate)
      unratedPhotoIconView.image = unratedPhotoIconView.image?.imageWithRenderingMode(.AlwaysTemplate)
      
      
      if badges?.hasMeetingToday == true {
        appointmentsLabelHeightConstraint.constant = labelHeight
        appointmentIconHeightConstraint.constant = iconHeight
      }
      if badges?.hasUnreadMessages == true {
        newMessagesLabelHeightConstraint.constant = labelHeight
        newMessageIconHeightConstraint.constant = iconHeight
        newMessageIconView.tintColor = ThemeManager.currentTheme().highlightColor
      }
      if badges?.hasUnratedPhotos == true {
        unratedPhotosHeightConstraint.constant = labelHeight
        unratedPhotoIconHeightConstraint.constant = iconHeight
      }
      
      
    }
  }

  func didTapCell(sender: UITapGestureRecognizer) {
    switch sender.state {
    case .Began:
      cellBackgroundView.backgroundColor = ThemeManager.currentTheme().highlightColor
    case .Ended:
      cellBackgroundView.backgroundColor = UIColor.clearColor()
    default:
      break
    }
    
  }
  
  override func awakeFromNib() {
    super.awakeFromNib()
//    self.selectionStyle = .None
    
    cellBackgroundView.layer.cornerRadius = 8.0
    cellBackgroundView.clipsToBounds = true
    cellBackgroundView.layer.borderColor = UIColor.blackColor().CGColor
    cellBackgroundView.layer.borderWidth = 2.0
    
  }
  
  override func setSelected(selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    
  }
  
  override func prepareForReuse() {
    avatarImage.image = nil
  }
  
  
}
