//
//  UIColor+AMRColor.swift
//  ArmoireApp
//
//  Created by Randy Ting on 10/28/15.
//  Copyright © 2015 Armoire. All rights reserved.
//

import Foundation

extension UIColor {
  //TODO name these something matching Theme.swift
  class func AMRPrimaryBackgroundColor() -> UIColor {
    //return
    return ThemeManager.currentTheme().backgroundColor
  }
  
  class func AMRSecondaryBackgroundColor() -> UIColor {
    //return
    return ThemeManager.currentTheme().mainColorSecondary
  }
 
  class func AMRBrightButtonBackgroundColor() -> UIColor {
    return ThemeManager.currentTheme().highlightColor
  }
  
  class func AMRBrightButtonTintColor() -> UIColor {

    return ThemeManager.currentTheme().mainColor
  }
  
  class func AMRUnselectedTabBarButtonTintColor() -> UIColor {
    return ThemeManager.currentTheme().backgroundColorSecondary
  }
  
  class func AMRClientUnselectedTabBarButtonTintColor() -> UIColor {
    return ThemeManager.currentTheme().mainColor
  }
  
  class func AMRSelectedTabBarButtonTintColor() -> UIColor {
    return ThemeManager.currentTheme().highlightColor
  }
  
  class func AMRClientNotificationIconColor() -> UIColor{
    return ThemeManager.currentTheme().highlightColor
  }
  
  class func AMRClientCollectionLabel() -> UIColor{
    return ThemeManager.currentTheme().mainColorSecondary
  }

  class func AMRLikeRatingIconTintColor() -> UIColor {
    return ThemeManager.currentTheme().likeIconColor
  }
  
  class func AMRNeutralRatingIconTintColor() -> UIColor {
    return ThemeManager.currentTheme().neutralIconColor
  }
  
  class func AMRDislikeRatingIconTintColor() -> UIColor {
    return ThemeManager.currentTheme().dislikeIconColor
  }
  
  class func AMRLoveRatingIconTintColor() -> UIColor {
    return ThemeManager.currentTheme().loveIconColor
  }
  
}
