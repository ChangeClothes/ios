//
//  AppDelegate.swift
//  ArmoireApp
//
//  Created by Randy Ting on 10/13/15.
//  Copyright © 2015 Armoire. All rights reserved.
//

import UIKit

let kCurrentUserKey = "com.ArmoireApp.currentUserKey"
let kUserDidLogoutNotification = "com.ArmoireApp.userDidLogoutNotification"
let kUserDidLoginNotification = "com.ArmoireApp.userDidLoginNotification"

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  
  var window: UIWindow?
  var mainVC: AMRMainViewController?
  var loginVC: AMRLoginViewController?
  var signUpVC: AMRSignUpViewController?
  
  func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
    
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "userDidLogout:", name: kUserDidLogoutNotification, object: nil)
    
    AMRUser.registerSubclass()
    AMRMeeting.registerSubclass()
    AMRNote.registerSubclass()
    let credentials = Credentials.defaultCredentials
    Parse.setApplicationId(credentials.ApplicationID, clientKey: credentials.ClientKey)
    
    window = UIWindow(frame: UIScreen.mainScreen().bounds)
    mainVC = AMRMainViewController()
    
    signUpVC = AMRSignUpViewController()
    signUpVC?.delegate = self
    
    loginVC = AMRLoginViewController()
    loginVC?.delegate = self
    loginVC?.customSignUpViewController = signUpVC
    
    if let _ = AMRUser.currentUser() {
      window?.rootViewController = mainVC
    } else {
      window?.rootViewController = loginVC
    }
    
    window?.makeKeyAndVisible()
    
    return true
  }
  
  func userDidLogout(sender: NSNotification){
    window?.rootViewController = loginVC
  }
  
  func applicationWillResignActive(application: UIApplication) {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
  }
  
  func applicationDidEnterBackground(application: UIApplication) {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
  }
  
  func applicationWillEnterForeground(application: UIApplication) {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
  }
  
  func applicationDidBecomeActive(application: UIApplication) {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
  }
  
  func applicationWillTerminate(application: UIApplication) {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
  }
  
  struct Credentials {
    static let defaultCredentialsFile = "Credentials"
    static let defaultCredentials     = Credentials.loadFromPropertyListNamed(defaultCredentialsFile)
    
    let ApplicationID: String
    let ClientKey: String
    
    private static func loadFromPropertyListNamed(name: String) -> Credentials {
      let path           = NSBundle.mainBundle().pathForResource(name, ofType: "plist")!
      let dictionary     = NSDictionary(contentsOfFile: path)!
      let applicationID    = dictionary["ApplicationID"] as! String
      let clientKey = dictionary["ClientKey"] as! String
      
      return Credentials(ApplicationID: applicationID, ClientKey: clientKey)
    }
  }
  
  deinit {
    NSNotificationCenter.defaultCenter().removeObserver(self)
  }
}

extension AppDelegate: PFLogInViewControllerDelegate {
  func logInViewController(logInController: PFLogInViewController, didLogInUser user: PFUser) {
    window?.rootViewController = mainVC
    NSNotificationCenter.defaultCenter().postNotificationName(kUserDidLoginNotification, object: self)
  }
  
}

extension AppDelegate: AMRSignUpViewControllerDelegate {
  func signUpViewController(signUpViewController: AMRSignUpViewController, didFailToSignUpWithError: NSError) {
    print(didFailToSignUpWithError.localizedDescription)
    signUpViewController.dismissViewControllerAnimated(true, completion: nil)
  }
  
  func signUpViewController(signUpViewController: AMRSignUpViewController, didSignUpUser: AMRUser) {
    signUpViewController.dismissViewControllerAnimated(true, completion: nil)
  }
  
  func signUpViewControllerDidCancelSignUp(signUpViewController: AMRSignUpViewController) {
    signUpViewController.dismissViewControllerAnimated(true, completion: nil)
  }

}

