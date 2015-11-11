//
//  imageCollectionViewCell.swift
//  ArmoireApp
//
//  Created by Mathew Kellogg on 10/28/15.
//  Copyright © 2015 Armoire. All rights reserved.
//

import UIKit

class imageCollectionViewCell: UICollectionViewCell {
  

  @IBOutlet weak var imageView: UIImageView!
  var activityIndicatorView: UIActivityIndicatorView!
  
  override func awakeFromNib() {
    super.awakeFromNib()
    imageView.contentMode = UIViewContentMode.ScaleAspectFill
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
