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
  @IBOutlet weak var messageIcon: UIImageView!
  @IBOutlet weak var imageView: UIImageView!
  @IBOutlet weak var calendarIcon: UIImageView!
  @IBOutlet weak var photoIcon: UIImageView!
  var client: AMRUser! {
    didSet{
      nameLabel.text = client.fullName
    }
  }
  var activityIndicatorView: UIActivityIndicatorView!

  override func awakeFromNib() {
    super.awakeFromNib()
    setIcons()
    imageView.contentMode = UIViewContentMode.ScaleAspectFill
    imageView.layer.cornerRadius = 50
    imageView.clipsToBounds = true
  }

  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    initialize()
  }

  override init(frame: CGRect) {
    super.init(frame: frame)
    initialize()
  }

  func initialize (){
    activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
    activityIndicatorView.startAnimating()
    addSubview(activityIndicatorView)
  }
  
  private func setIcons(){
    for icon in [messageIcon, calendarIcon, photoIcon]{
      icon.image = icon.image?.imageWithRenderingMode(.AlwaysTemplate)
      icon.tintColor = UIColor.AMRClientNotificationIconColor()
    }
  }
}
