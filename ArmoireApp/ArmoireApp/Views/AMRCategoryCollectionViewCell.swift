//
//  AMRCategoryCollectionViewCell.swift
//  ArmoireApp
//
//  Created by Morgan Wildermuth on 11/13/15.
//  Copyright © 2015 Armoire. All rights reserved.
//

import UIKit

class AMRCategoryCollectionViewCell: UICollectionViewCell {

  @IBOutlet weak var constraintImageWidth: NSLayoutConstraint!
  @IBOutlet weak var constraintImageHeight: NSLayoutConstraint!
  @IBOutlet weak var imageView: UIImageView!
  @IBOutlet weak var nameLabel: UILabel!

  var category: AMRInventoryCategory! {
    didSet{
      nameLabel.text = category.name
      if category.name == "Women"{
        imageView.image = UIImage(named: "female")
        constraintImageHeight.constant = 150
        constraintImageWidth.constant = 150
      } else if category.name == "Men"{
        imageView.image = UIImage(named: "male")
        constraintImageWidth.constant = 150
        constraintImageHeight.constant = 150
      } else if let checkedUrl = NSURL(string: category.imageUrl!) {
        imageView.contentMode = .ScaleAspectFit
        setImageValue(checkedUrl)
      }
    }
  }

  override func awakeFromNib() {
      super.awakeFromNib()
      // Initialization code
  }

  override func prepareForReuse() {
    self.imageView.image = nil;
  }

  func getDataFromUrl(url:NSURL, completion: ((data: NSData?, response: NSURLResponse?, error: NSError? ) -> Void)) {
    NSURLSession.sharedSession().dataTaskWithURL(url) { (data, response, error) in
      completion(data: data, response: response, error: error)
      }.resume()
  }

  func setImageValue(url: NSURL){
    getDataFromUrl(url) { (data, response, error)  in
      dispatch_async(dispatch_get_main_queue()) { () -> Void in
        guard let data = data where error == nil else { return }
        self.imageView.image = UIImage(data: data)
      }
    }
  }
}
