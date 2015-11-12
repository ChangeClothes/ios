//
//  AMRDynamicHeightCellTableViewCell.swift
//  ArmoireApp
//
//  Created by Mathew Kellogg on 11/11/15.
//  Copyright © 2015 Armoire. All rights reserved.
//

import UIKit

class AMRDynamicHeightTableViewCell: UITableViewCell {
  
  static func getDefaultHeight() -> CGFloat{
    return CGFloat(100)
  }
  
  func getCellHeight() -> CGFloat{
    return getCellHeight(CGFloat(300))
  }

 
  func getCellHeight(width: CGFloat?) -> CGFloat{
    return AMRDynamicHeightTableViewCell.getDefaultHeight()
  }

}
