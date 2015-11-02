//
//  imageCollectionViewCell.swift
//  ArmoireApp
//
//  Created by Mathew Kellogg on 10/28/15.
//  Copyright © 2015 Armoire. All rights reserved.
//

import UIKit

class imageCollectionViewCell: UICollectionViewCell {
  
  var imageView: UIImageView!
  
  override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }

  override init(frame: CGRect) {
    super.init(frame: frame)
    
    imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height))
    imageView.contentMode = UIViewContentMode.ScaleAspectFill
    imageView.layer.cornerRadius = 5.0
    imageView.clipsToBounds = true
    contentView.addSubview(imageView)
  }

}
