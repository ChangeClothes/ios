//
//  UIAlertController+AMRSettingsController.swift
//  ArmoireApp
//
//  Created by Mathew Kellogg on 10/31/15.
//  Copyright © 2015 Armoire. All rights reserved.
//

import Foundation

enum AMRSettingsControllerSetting: String {
  case Logout = "Logout", Cancel = "Cancel"
}

extension UIAlertController {
  
  class func AMRSettingsController(completion:(AMRSettingsControllerSetting) -> ()) -> UIAlertController {
    return UIAlertController.AMRSettingsController([AMRSettingsControllerSetting.Logout], completion: completion)
  }
  
  class func AMRSettingsController(settings:[AMRSettingsControllerSetting], completion:(AMRSettingsControllerSetting) -> ()) -> UIAlertController {
    
    let controller = UIAlertController(title: "Settings", message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
    let handler: (UIAlertAction) -> () = {
      action in
      let setting = AMRSettingsControllerSetting(rawValue: action.title!)!
      if setting == AMRSettingsControllerSetting.Logout {
        PFUser.logOutInBackgroundWithBlock { (error: NSError?) -> Void in
          if let error = error {
            print(error.localizedDescription)
          } else {
            NSNotificationCenter.defaultCenter().postNotificationName(kUserDidLogoutNotification, object: self)
          }
        }
      }
      completion(setting)
    }
    
    for setting in settings {
      controller.addAction(UIAlertAction(title: setting.rawValue, style: UIAlertActionStyle.Default, handler: handler))
    }
    controller.addAction(UIAlertAction(title: AMRSettingsControllerSetting.Cancel.rawValue, style: UIAlertActionStyle.Cancel, handler: handler))
    
    return controller
  }
}