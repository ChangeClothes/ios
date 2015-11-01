//
//  UIAlertController+AMRSettingsController.swift
//  ArmoireApp
//
//  Created by Mathew Kellogg on 10/31/15.
//  Copyright © 2015 Armoire. All rights reserved.
//

import Foundation

enum AMRSettingsControllerSetting: String {
  case Logout = "Logout", ProfilePicture = "Change Profile Picture", Cancel = "Cancel"
}

extension UIAlertController {
  
  class func AMRSettingsController(completion:(AMRSettingsControllerSetting) -> ()) -> UIAlertController {
    return UIAlertController.AMRSettingsController([AMRSettingsControllerSetting.ProfilePicture, AMRSettingsControllerSetting.Logout], completion: completion)
  }
  
  class func AMRSettingsController(settings:[AMRSettingsControllerSetting], completion:(AMRSettingsControllerSetting) -> ()) -> UIAlertController {
    
    let controller = UIAlertController(title: "Settings", message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
    let handler: (UIAlertAction) -> () = {
      action in
      let setting = AMRSettingsControllerSetting(rawValue: action.title!)!
      switch (setting) {
        
      case AMRSettingsControllerSetting.Logout:
        PFUser.logOutInBackgroundWithBlock { (error: NSError?) -> Void in
          if let error = error {
            print(error.localizedDescription)
          } else {
            NSNotificationCenter.defaultCenter().postNotificationName(kUserDidLogoutNotification, object: self)
          }
        }
      default:
        break
        
      }
      completion(setting)
    }
    
    for setting in settings + [AMRSettingsControllerSetting.Cancel] {
      switch setting {
      case AMRSettingsControllerSetting.Cancel:
        let alertAction = UIAlertAction(title: setting.rawValue, style: UIAlertActionStyle.Cancel, handler: handler)
        controller.addAction(alertAction)
      case AMRSettingsControllerSetting.ProfilePicture:
        let alertAction = UIAlertAction(title: setting.rawValue, style: UIAlertActionStyle.Default, handler: handler)
        var resizedImage: UIImage
        if let imageData = CurrentUser.sharedInstance.user?.profilePhoto{
          let image = UIImage(data:imageData.getData()!)
          resizedImage = UIImage.roundedRectImageFromImage(image!, imageSize:
          CGSize(width: 75, height: 75), cornerRadius: 37.5)
          resizedImage = resizedImage.imageWithRenderingMode(.AlwaysOriginal)
        } else {
          let image = UIImage(named: "camera")
          resizedImage = AMRSquareImageTo(image!, size: CGSize(width: 75, height: 75))
        }
        alertAction.setValue(resizedImage, forKey: "image")
        
        controller.addAction(alertAction)
          
      default:
        controller.addAction(UIAlertAction(title: setting.rawValue, style: UIAlertActionStyle.Default, handler: handler))
      }
    }
    
    return controller
  }
}
