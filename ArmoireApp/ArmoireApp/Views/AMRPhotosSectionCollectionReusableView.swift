//
//  AMRPhotosSectionCollectionReusableView.swift
//  ArmoireApp
//
//  Created by Randy Ting on 11/8/15.
//  Copyright © 2015 Armoire. All rights reserved.
//

import UIKit

class AMRPhotosSectionCollectionReusableView: UICollectionReusableView {
  
  @IBOutlet weak var sectionTitleLabel: UILabel!
  
  override func awakeFromNib() {
    super.awakeFromNib()
    setupAppearance()
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
  }
  
  private func setupAppearance() {
    backgroundColor = UIColor.AMRSecondaryBackgroundColor()
    sectionTitleLabel.textColor = UIColor.whiteColor()
  }
  
}
