//
//  UIColor+AMRColor.swift
//  ArmoireApp
//
//  Created by Randy Ting on 10/28/15.
//  Copyright © 2015 Armoire. All rights reserved.
//

import Foundation

extension UIColor {
  
  class func AMRBackgroundColor() -> UIColor {
    return ColorHelper.sharedInstance.colorFromHexString("#7f8c8d")
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