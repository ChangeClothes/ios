//
//  Theme.swift
//  ArmoireApp
//
//  Created by Mathew Kellogg on 11/2/15.
//  Copyright © 2015 Armoire. All rights reserved.
//

import UIKit

enum Theme: Int {
  case Default, Theme1
  
  var mainColor: UIColor {
    switch self {
    case .Default:
      return ColorHelper.sharedInstance.colorFromHexString("#E1DBDA")
      //return ColorHelper.sharedInstance.colorFromHexString("#E1DBDA")
    case .Theme1:
      return ColorHelper.sharedInstance.colorFromHexString("#937250")
    }
  }
  
  var mainColorSecondary: UIColor {
    switch self {
    case .Default:
      return ColorHelper.sharedInstance.colorFromHexString("#0172C9")
      //return ColorHelper.sharedInstance.colorFromHexString("#28B9AD")
    case .Theme1:
      return ColorHelper.sharedInstance.colorFromHexString("#58C0E1")
    }
  }
  
  var barStyle: UIBarStyle {
    switch self {
    case .Default:
      return .Default
    case .Theme1:
      //return .Black
      return .Default
    }
  }
  
  var backgroundColor: UIColor {
    switch self {
    case .Default:
      return ColorHelper.sharedInstance.colorFromHexString("#58C0E1")
    case .Theme1:
      return ColorHelper.sharedInstance.colorFromHexString("#FFFFFF")
    }
  }
  var backgroundColorSecondary: UIColor {
    switch self {
    case .Default:
      return ColorHelper.sharedInstance.colorFromHexString("#0172C9")
    case .Theme1:
      return ColorHelper.sharedInstance.colorFromHexString("#F7F1F1")
    }
  }
  
  var highlightColor: UIColor {
    switch self {
    case .Default:
      return ColorHelper.sharedInstance.colorFromHexString("#FFB276")
    case .Theme1:
      return ColorHelper.sharedInstance.colorFromHexString("#FA5B52")
    }
  }
}

let SelectedThemeKey = "SelectedTheme"

struct ThemeManager {
  
  static func currentTheme() -> Theme {
    
    return .Theme1
    if let storedTheme = NSUserDefaults.standardUserDefaults().valueForKey(SelectedThemeKey)?.integerValue {
      print("Theme: \(Theme(rawValue: storedTheme)!))")
      return Theme(rawValue: storedTheme)!
    } else {
      let thetheme: Theme = .Default
      print("Theme: \(thetheme)")
      return .Default
    }
  }
  
  static func applyTheme(theme: Theme) {
    NSUserDefaults.standardUserDefaults().setValue(theme.rawValue, forKey: SelectedThemeKey)
    NSUserDefaults.standardUserDefaults().synchronize()
   
    let sharedApplication = UIApplication.sharedApplication()
    sharedApplication.delegate?.window??.tintColor = theme.mainColor
    
    UINavigationBar.appearance().barStyle = theme.barStyle
    UINavigationBar.appearance().tintColor = theme.mainColorSecondary
    UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName:theme.mainColorSecondary]
    //UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName:theme.mainColorSecondary, UIControlState:.Highlighted]
    UINavigationBar.appearance().barTintColor = theme.backgroundColorSecondary
    UINavigationBar.appearance().backgroundColor = theme.backgroundColorSecondary
    
    UITabBar.appearance().barStyle = theme.barStyle

    
    
    
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
