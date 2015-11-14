//
//  AMRCategoryCollectionViewCell.swift
//  ArmoireApp
//
//  Created by Morgan Wildermuth on 11/13/15.
//  Copyright © 2015 Armoire. All rights reserved.
//

import UIKit

class AMRCategoryCollectionViewCell: UICollectionViewCell {

  @IBOutlet weak var imageView: UIImageView!
  @IBOutlet weak var nameLabel: UILabel!

  var category: AMRInventoryCategory! {
    didSet{
      nameLabel.text = category.name
      setImageValue()
    }
  }

  override func awakeFromNib() {
      super.awakeFromNib()
      // Initialization code
  }

  func setImageValue(){
//    let image_url = NSURL(string: category.imageUrl!)
//    let url_request = NSURLRequest(URL: image_url!)
//    let placeholder = UIImage(named: "no_photo")
//    self.imageView.set
  }

}
