//
//  AMRViewController.swift
//  ArmoireApp
//
//  Created by Randy Ting on 11/8/15.
//  Copyright © 2015 Armoire. All rights reserved.
//

import UIKit

class AMRViewController: UIViewController {

  var stylist: AMRUser?
  var client: AMRUser?
  
  func showSettings () {
    let settingsVC = UIAlertController.AMRSettingsController { (setting: AMRSettingsControllerSetting) -> () in
      if setting == AMRSettingsControllerSetting.ProfilePicture {
        PhotoPicker.sharedInstance.selectPhoto(self.stylist, client: self.client, viewDelegate: self, completion: {
          (image: AMRImage) -> () in
          let user = CurrentUser.sharedInstance.user
          user?.profilePhoto = image
          user?.saveInBackground()
        })
      } else if setting == AMRSettingsControllerSetting.Template {
        let vc = AMRQANotesViewController()
        vc.stylist = self.stylist
        vc.client = self.client
        let navController = UINavigationController(rootViewController: vc)
        self.presentViewController(navController, animated: true, completion: { () -> Void in
        })
      }
    }
    self.presentViewController(settingsVC, animated: true, completion: nil)
  }

  internal func setVcData(stylist: AMRUser?, client: AMRUser?) {
    self.stylist = stylist
    self.client = client
  }
}
