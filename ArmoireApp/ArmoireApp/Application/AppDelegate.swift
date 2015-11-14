//
//  AppDelegate.swift
//  ArmoireApp
//
//  Created by Randy Ting on 10/13/15.
//  Copyright © 2015 Armoire. All rights reserved.
//

import UIKit
import LayerKit

let kCurrentUserKey = "com.ArmoireApp.currentUserKey"
let kUserDidLogoutNotification = "com.ArmoireApp.userDidLogoutNotification"
let kUserDidLoginNotification = "com.ArmoireApp.userDidLoginNotification"
let kProfileImageChanged = "com.ArmoireApp.profileImageChanged"
let kNewMessageIconShown = "com.ArmoireApp.newMessageIconShown"
let kNewMessageIconHidden = "com.ArmoireApp.newMessageIconHidden"
let AMRMainShowMenuView = "com.ArmoireApp.mainShowMenuView"
let AMRMainHideMenuView = "com.ArmoireApp.mainHideMenuView"
let AMRErrorDomain = "com.ArmoireApp.errorDomain"
let kDismissedModalNotification = "com.ArmoireApp.dismissedModalNotification"

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  
  var window: UIWindow?
  var mainVC: AMRMainViewController?
  var loginVC: AMRLoginViewController?
  var signUpVC: AMRSignUpViewController?
  var layerClient: LYRClient!
  
  func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
    
    AMRInventory.get_inventory({ (inventory) -> () in
     AMRInventory.sharedInstance = inventory
    })
    
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "userDidLogout:", name: kUserDidLogoutNotification, object: nil)
    
    setupParse()
    setupLayer()
//    registerApplicationForPushNotifications(application)
    
    let theme = ThemeManager.currentTheme()
    ThemeManager.applyTheme(theme)
    
    window = UIWindow(frame: UIScreen.mainScreen().bounds)
    mainVC = AMRMainViewController()
    mainVC?.layerClient = layerClient
    
    signUpVC = AMRSignUpViewController()
    signUpVC?.delegate = self
    
    loginVC = AMRLoginViewController()
    loginVC?.delegate = self
    loginVC?.customSignUpViewController = signUpVC
    
    if let _ = AMRUser.currentUser() {
      loginLayer()
      window?.rootViewController = mainVC
    } else {
      window?.rootViewController = loginVC
    }
    
    CurrentUser.sharedInstance.setCurrentUser()
    
    window?.makeKeyAndVisible()
    
    return true
  }
  
  // MARK: - Logout
  func userDidLogout(sender: NSNotification){
    self.layerClient.deauthenticateWithCompletion { success, error in
      if (!success) {
        print("Failed to deauthenticate: \(error)")
      } else {
        print("Previous user deauthenticated")
      }
    }
    
    window?.rootViewController = loginVC
  }
  
  // MARK: - Initial Setup
  private func setupParse() {
    
    //register subclasses
    AMRUser.registerSubclass()
    AMRMeeting.registerSubclass()
    AMRNote.registerSubclass()
    AMRImage.registerSubclass()
    AMRMeasurements.registerSubclass()
    AMRQuestionAnswer.registerSubclass()

    // set credentials
    let credentials = Credentials.defaultCredentials
    Parse.setApplicationId(credentials.ParseApplicationID, clientKey: credentials.ParseClientKey)
  }
  
  private func setupLayer() {
    layerClient = LYRClient(appID: NSURL(string: Credentials.defaultCredentials.LayerApplicationID))
    layerClient.autodownloadMIMETypes = NSSet(objects: ATLMIMETypeImagePNG, ATLMIMETypeImageJPEG, ATLMIMETypeImageJPEGPreview, ATLMIMETypeImageGIF, ATLMIMETypeImageGIFPreview, ATLMIMETypeLocation) as Set<NSObject>
  }
  
  // MARK: - Lifecycle
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
  
  // MARK:- Push Notification Registration
  
  func registerApplicationForPushNotifications(application: UIApplication) {
    // Set up push notifications
    // For more information about Push, check out:
    // https://developer.layer.com/docs/guides/ios#push-notification
    
    
    let notificationSettings: UIUserNotificationSettings = UIUserNotificationSettings(forTypes: [UIUserNotificationType.Alert, UIUserNotificationType.Badge, UIUserNotificationType.Sound], categories: nil)
    application.registerUserNotificationSettings(notificationSettings)
    application.registerForRemoteNotifications()
    
  }
  
  func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
    // Store the deviceToken in the current installation and save it to Parse.
    let currentInstallation: PFInstallation = PFInstallation.currentInstallation()
    currentInstallation.setDeviceTokenFromData(deviceToken)
    currentInstallation.saveInBackground()
    
    // Send device token to Layer so Layer can send pushes to this device.
    // For more information about Push, check out:
    // https://developer.layer.com/docs/ios/guides#push-notification
    assert(self.layerClient != nil, "The Layer client has not been initialized!")
    do {
      try? self.layerClient.updateRemoteNotificationDeviceToken(deviceToken)
      print("Application did register for remote notifications: \(deviceToken)")
    } catch let error as NSError {
      print("Failed updating device token with error: \(error)")
    }
  }
  
  func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject], fetchCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
    if userInfo["layer"] == nil {
      PFPush.handlePush(userInfo)
      completionHandler(UIBackgroundFetchResult.NewData)
      return
    }
    
    let userTappedRemoteNotification: Bool = application.applicationState == UIApplicationState.Inactive
    var conversation: LYRConversation? = nil
    if userTappedRemoteNotification {
      //      SVProgressHUD.show()
      conversation = self.conversationFromRemoteNotification(userInfo)
      if conversation != nil {
        self.navigateToViewForConversation(conversation!)
      }
    }
    
    let success: Bool = self.layerClient.synchronizeWithRemoteNotification(userInfo, completion: { (changes, error) in
      completionHandler(self.getBackgroundFetchResult(changes, error: error))
      
      if userTappedRemoteNotification && conversation == nil {
        // Try navigating once the synchronization completed
        self.navigateToViewForConversation(self.conversationFromRemoteNotification(userInfo))
      }
    })
    
    if !success {
      // This should not happen?
      completionHandler(UIBackgroundFetchResult.NoData)
    }
  }
  
  func getBackgroundFetchResult(changes: [AnyObject]!, error: NSError!) -> UIBackgroundFetchResult {
    if changes?.count > 0 {
      return UIBackgroundFetchResult.NewData
    }
    return error != nil ? UIBackgroundFetchResult.Failed : UIBackgroundFetchResult.NoData
  }
  
  func conversationFromRemoteNotification(remoteNotification: [NSObject : AnyObject]) -> LYRConversation {
    let layerMap = remoteNotification["layer"] as! [String: String]
    let conversationIdentifier = NSURL(string: layerMap["conversation_identifier"]!)
    return self.existingConversationForIdentifier(conversationIdentifier!)!
  }
  
  // TODO: Implement this functionality
  func navigateToViewForConversation(conversation: LYRConversation) {
//    if self.controller.conversationListViewController != nil {
//      dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(2 * Double(NSEC_PER_SEC))), dispatch_get_main_queue(), {
////        SVProgressHUD.dismiss()
//        if (self.controller.navigationController!.topViewController as? ConversationViewController)?.conversation != conversation {
//          self.controller.conversationListViewController.presentConversation(conversation)
//        }
//      });
//    } else {
////      SVProgressHUD.dismiss()
//    }
  }

  func existingConversationForIdentifier(identifier: NSURL) -> LYRConversation? {
    let query: LYRQuery = LYRQuery(queryableClass: LYRConversation.self)
    query.predicate = LYRPredicate(property: "identifier", predicateOperator: LYRPredicateOperator.IsEqualTo, value: identifier)
    query.limit = 1
    do {
      return try self.layerClient.executeQuery(query).firstObject as? LYRConversation
    } catch {
      // This should never happen?
      return nil
    }
  }
  
  
  // MARK: - Fixture
  struct Credentials {
    static let defaultCredentialsFile = "Credentials"
    static let defaultCredentials     = Credentials.loadFromPropertyListNamed(defaultCredentialsFile)
    
    let ParseApplicationID: String
    let ParseClientKey: String
    let LayerApplicationID: String
    
    private static func loadFromPropertyListNamed(name: String) -> Credentials {
      let path           = NSBundle.mainBundle().pathForResource(name, ofType: "plist")!
      let dictionary     = NSDictionary(contentsOfFile: path)!
      let parseApplicationID = dictionary["ParseApplicationID"] as! String
      let parseClientKey = dictionary["ParseClientKey"] as! String
      let layerApplicationID = dictionary["LayerApplicationID"] as! String
      
      return Credentials(ParseApplicationID: parseApplicationID, ParseClientKey: parseClientKey, LayerApplicationID: layerApplicationID)
    }
  }
  
  deinit {
    NSNotificationCenter.defaultCenter().removeObserver(self)
  }
}

// MARK: - PFLogInViewController Delegate
extension AppDelegate: AMRLoginViewControllerDelegate {
  func logInViewController(logInController: AMRLoginViewController, didLoginUser user: PFUser) {
    loginLayer()
  }
  
  private func loginLayer() {
    //    SVProgressHUD.show()
    
    // Connect to Layer
    // See "Quick Start - Connect" for more details
    // https://developer.layer.com/docs/quick-start/ios#connect
    self.layerClient.connectWithCompletion { success, error in
      if (!success) {
        print("Failed to connect to Layer: \(error)")
      } else {
        let userID: String = PFUser.currentUser()!.objectId!
        // Once connected, authenticate user.
        // Check Authenticate step for authenticateLayerWithUserID source
        self.authenticateLayerWithUserID(userID, completion: { success, error in
          if (!success) {
            print("Failed Authenticating Layer Client with error:\(error)")
          } else {
            print("Authenticated")
            //            self.presentConversationListViewController()
            self.window?.rootViewController = self.mainVC
            NSNotificationCenter.defaultCenter().postNotificationName(kUserDidLoginNotification, object: self)
          }
        })
      }
    }
  }
  
  private func authenticateLayerWithUserID(userID: NSString, completion: ((success: Bool , error: NSError!) -> Void)!) {
    // Check to see if the layerClient is already authenticated.
    if self.layerClient.authenticatedUserID != nil {
      // If the layerClient is authenticated with the requested userID, complete the authentication process.
      if self.layerClient.authenticatedUserID == userID {
        print("Layer Authenticated as User \(self.layerClient.authenticatedUserID)")
        if completion != nil {
          completion(success: true, error: nil)
        }
        return
      } else {
        //If the authenticated userID is different, then deauthenticate the current client and re-authenticate with the new userID.
        self.layerClient.deauthenticateWithCompletion { (success: Bool, error: NSError!) in
          if error != nil {
            self.authenticationTokenWithUserId(userID, completion: { (success: Bool, error: NSError?) in
              if (completion != nil) {
                completion(success: success, error: error)
              }
            })
          } else {
            if completion != nil {
              completion(success: true, error: error)
            }
          }
        }
      }
    } else {
      // If the layerClient isn't already authenticated, then authenticate.
      self.authenticationTokenWithUserId(userID, completion: { (success: Bool, error: NSError!) in
        if completion != nil {
          completion(success: success, error: error)
        }
      })
    }
  }
  
  private func authenticationTokenWithUserId(userID: NSString, completion:((success: Bool, error: NSError!) -> Void)!) {
    /*
    * 1. Request an authentication Nonce from Layer
    */
    self.layerClient.requestAuthenticationNonceWithCompletion { (nonce: String!, error: NSError!) in
      if (nonce.isEmpty) {
        if (completion != nil) {
          completion(success: false, error: error)
        }
        return
      }
      
      /*
      * 2. Acquire identity Token from Layer Identity Service
      */
      PFCloud.callFunctionInBackground("generateToken", withParameters: ["nonce": nonce, "userID": userID]) { (object:AnyObject?, error: NSError?) -> Void in
        if error == nil {
          let identityToken = object as! String
          self.layerClient.authenticateWithIdentityToken(identityToken) { authenticatedUserID, error in
            if (!authenticatedUserID.isEmpty) {
              if (completion != nil) {
                completion(success: true, error: nil)
              }
              print("Layer Authenticated as User: \(authenticatedUserID)")
            } else {
              completion(success: false, error: error)
            }
          }
        } else {
          print("Parse Cloud function failed to be called to generate token with error: \(error)")
        }
      }
    }
  }
  
  
  
}

// MARK: - AMRSignUpViewController Delegate
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

