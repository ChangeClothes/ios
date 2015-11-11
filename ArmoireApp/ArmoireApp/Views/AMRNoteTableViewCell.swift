//
//  AMRNoteTableViewCell.swift
//  ArmoireApp
//
//  Created by Mathew Kellogg on 11/8/15.
//  Copyright © 2015 Armoire. All rights reserved.
//

import UIKit


class AMRNoteTableViewCell: AMRDynamicHeightTableViewCell {
  
  
  class func cellReuseIdentifier() -> String{
    return "com.armoire.AMRNoteTableViewCell"
  }
  
  override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
  }
  @IBOutlet weak var contents: UITextView!

  override func setSelected(selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    
  }
  
  override func getCellHeight(width:CGFloat?) -> CGFloat {
    let heightMargins = CGFloat(24)
    let widthMargins = CGFloat(16)
    var fixedWidth: CGFloat
    if let suggestedWidth = width {
      fixedWidth = suggestedWidth - widthMargins
    } else {
      fixedWidth = contents.frame.size.width
    }
    let newSize : CGSize = contents.sizeThatFits(CGSizeMake(fixedWidth, CGFloat(MAXFLOAT)))
    var newFrame : CGRect = contents.frame
    newFrame.size = CGSizeMake(CGFloat(fmaxf((Float)(newSize.width), (Float)(fixedWidth))),newSize.height)
    return newFrame.height + heightMargins
  }
  
}
