//
//  clientCollectionViewCell.swift
//  ArmoireApp
//
//  Created by Morgan Wildermuth on 11/11/15.
//  Copyright © 2015 Armoire. All rights reserved.
//

import UIKit

class clientCollectionViewCell: UICollectionViewCell {

  @IBOutlet weak var imageView: UIImageView!
  var activityIndicatorView: UIActivityIndicatorView!

  override func awakeFromNib() {
    super.awakeFromNib()
    imageView.contentMode = UIViewContentMode.ScaleAspectFill
    imageView.layer.cornerRadius = 5.0
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
}
