//
//  clientCollectionViewCell.swift
//  ArmoireApp
//
//  Created by Morgan Wildermuth on 11/11/15.
//  Copyright © 2015 Armoire. All rights reserved.
//

import UIKit

class clientCollectionViewCell: UICollectionViewCell {

  @IBOutlet weak var nameLabel: UILabel!
  @IBOutlet weak var lastNameLabel: UILabel!
  @IBOutlet weak var messageIcon: UIImageView!
  @IBOutlet weak var imageView: UIImageView!
  @IBOutlet weak var calendarIcon: UIImageView!
  @IBOutlet weak var photoIcon: UIImageView!
  
  var client: AMRUser! {
    didSet{
      nameLabel.text = client.firstName
      lastNameLabel.text = client.lastName
      showBadgesForClient(client)
      self.imageView.setAMRImage(client.profilePhoto, withPlaceholder: "profile-image-placeholder") { (success) -> Void in
      }
    }
  }

  override func awakeFromNib() {
    super.awakeFromNib()
    setupIcons()
    imageView.contentMode = UIViewContentMode.ScaleAspectFill
    imageView.layer.cornerRadius = 50
    imageView.clipsToBounds = true
  }

  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }

  override init(frame: CGRect) {
    super.init(frame: frame)
  }

  override func prepareForReuse() {
    self.imageView.image = nil;
    messageIcon.hidden = true
    calendarIcon.hidden = true
    photoIcon.hidden = true
  }

  private func setupIcons(){
    for icon in [messageIcon, calendarIcon, photoIcon]{
      icon.image = icon.image?.imageWithRenderingMode(.AlwaysTemplate)
      icon.tintColor = UIColor.whiteColor()
      icon.backgroundColor = ThemeManager.currentTheme().highlightColor
      icon.clipsToBounds = true
      icon.layer.cornerRadius = icon.frame.height/8
      icon.hidden = true
    }
  }
  
  private func showBadgesForClient(client: AMRUser){
    let clientBadges = AMRBadgeManager.sharedInstance.tempBadges[client.objectId!]
    if clientBadges?.hasUnratedPhotos == true {
      photoIcon.hidden = false
    }
    if clientBadges?.hasMeetingToday == true {
      calendarIcon.hidden = false
    }
    if clientBadges?.hasUnreadMessages == true {
      messageIcon.hidden = false
    }
    
  }
}
