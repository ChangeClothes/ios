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
      return ColorHelper.sharedInstance.colorFromHexString("#000000")
    }
  }
  
  var barStyle: UIBarStyle {
    switch self {
    case .Default:
      return .Default
    case .Theme1:
      return .Black
      //return .Default
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
      return ColorHelper.sharedInstance.colorFromHexString("#00D7FF")
      //return ColorHelper.sharedInstance.colorFromHexString("#58C0E1")
      //return ColorHelper.sharedInstance.colorFromHexString("#FA5B52")
    }
  }
  
  var loveIconColor: UIColor {
    switch self {
    case .Default:
      return ColorHelper.sharedInstance.colorFromHexString("#DB0A5B")
    case .Theme1:
      return ColorHelper.sharedInstance.colorFromHexString("#00D7FF")
      //return ColorHelper.sharedInstance.colorFromHexString("#58C0E1")
      //return ColorHelper.sharedInstance.colorFromHexString("#00D7FF")
    }
  }
  
  var likeIconColor: UIColor {
    switch self {
    case .Default:
      return ColorHelper.sharedInstance.colorFromHexString("#2ecc71")
    case .Theme1:
      return ColorHelper.sharedInstance.colorFromHexString("#00D7FF")
      //return ColorHelper.sharedInstance.colorFromHexString("#58C0E1")
      //return ColorHelper.sharedInstance.colorFromHexString("#00D7FF")
    }
  }
  
  var neutralIconColor: UIColor {
    switch self {
    case .Default:
      return ColorHelper.sharedInstance.colorFromHexString("#f39c12")
    case .Theme1:
      return ColorHelper.sharedInstance.colorFromHexString("#0183C9")
    }
  }
  
  var dislikeIconColor: UIColor {
    switch self {
    case .Default:
      return ColorHelper.sharedInstance.colorFromHexString("#c0392b")
    case .Theme1:
      return ColorHelper.sharedInstance.colorFromHexString("#003A65")
    }
  }
  
  var unratedIconColor: UIColor {
    switch self {
    case .Default:
      return ColorHelper.sharedInstance.colorFromHexString("#6C7A89")
    case .Theme1:
      return ColorHelper.sharedInstance.colorFromHexString("#6C7A89")
    }
  }
  
  var unselectedRatingIconColor: UIColor {
    switch self {
    case .Default:
      return ColorHelper.sharedInstance.colorFromHexString("#95a5a6")
    case .Theme1:
      return ColorHelper.sharedInstance.colorFromHexString("#95a5a6")
    }
  }
  
  var sectionHeaderBackgroundColor: UIColor {
    switch self {
    case .Default:
      return ColorHelper.sharedInstance.colorFromHexString("#ECECEC")
    case .Theme1:
      return ColorHelper.sharedInstance.colorFromHexString("#ECECEC")
    }
  }
  
  var todayViewCellBackgroundColor: UIColor {
    switch self {
    case .Default:
      return ColorHelper.sharedInstance.colorFromHexString("#ecf0f1")
    case .Theme1:
      return ColorHelper.sharedInstance.colorFromHexString("#ecf0f1")
    }
  }
  
}

let SelectedThemeKey = "SelectedTheme"

struct ThemeManager {
  
  static func currentTheme() -> Theme {
    
    return .Theme1
    /*
    if let storedTheme = NSUserDefaults.standardUserDefaults().valueForKey(SelectedThemeKey)?.integerValue {
      print("Theme: \(Theme(rawValue: storedTheme)!))")
      return Theme(rawValue: storedTheme)!
    } else {
      let thetheme: Theme = .Default
      print("Theme: \(thetheme)")
      return .Default
    }
    */
  }
  
  
  static func applyTheme(theme: Theme) {
    NSUserDefaults.standardUserDefaults().setValue(theme.rawValue, forKey: SelectedThemeKey)
    NSUserDefaults.standardUserDefaults().synchronize()
   
    let sharedApplication = UIApplication.sharedApplication()
    sharedApplication.delegate?.window??.tintColor = theme.mainColor
    
    UINavigationBar.appearance().barStyle = theme.barStyle
    UINavigationBar.appearance().tintColor = theme.backgroundColorSecondary
    UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName:theme.backgroundColorSecondary]
    UINavigationBar.appearance().barTintColor = theme.mainColorSecondary
    UINavigationBar.appearance().backgroundColor = theme.mainColorSecondary
    
    
    UITabBar.appearance().barStyle = theme.barStyle
    
    UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.LightContent, animated: false)
    
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
