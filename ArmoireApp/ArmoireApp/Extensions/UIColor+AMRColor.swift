//
//  UIColor+AMRColor.swift
//  ArmoireApp
//
//  Created by Randy Ting on 10/28/15.
//  Copyright © 2015 Armoire. All rights reserved.
//

import Foundation

extension UIColor {
  
  class func AMRPrimaryBackgroundColor() -> UIColor {
    return ColorHelper.sharedInstance.colorFromHexString("#7f8c8d")
  }
  
  class func AMRSecondaryBackgroundColor() -> UIColor {
    return ColorHelper.sharedInstance.colorFromHexString("#34495e")
  }
 
  class func AMRBrightButtonBackgroundColor() -> UIColor {
    return ColorHelper.sharedInstance.colorFromHexString("#ecf0f1")
  }
  
  class func AMRBrightButtonTintColor() -> UIColor {
    return ColorHelper.sharedInstance.colorFromHexString("#2c3e50")
  }
}

private struct ColorHelper {
  
  static let sharedInstance = ColorHelper()
  
  func colorFromHexString(hexString: String) -> UIColor {
    var rgbValue: UInt32 = 0
    let scanner = NSScanner(string: hexString)
    scanner.scanLocation = 1
    scanner.scanHexInt(&rgbValue)
    return UIColor(
      red: CGFloat((rgbValue >> 16) & 0xff) / 255,
      green: CGFloat((rgbValue >> 08) & 0xff) / 255,
      blue: CGFloat((rgbValue >> 00) & 0xff) / 255,
      alpha: 1.0)
  }
}