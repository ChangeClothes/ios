//
//  Reachability.swift
//  ArmoireApp
//
//  Created by Morgan Wildermuth on 11/15/15.
//  Copyright © 2015 Armoire. All rights reserved.
//

import Foundation

public class Reachability {
  
  let kActiveNetworkError = "com.armoire.activeNetworkErrorNotification"
  let kInactiveNetworkError = "com.armoire.inactiveNetworkErrorNotification"
  
  class func isConnectedToNetwork() -> Bool {
    
    var zeroAddress = sockaddr_in(sin_len: 0, sin_family: 0, sin_port: 0, sin_addr: in_addr(s_addr: 0), sin_zero: (0, 0, 0, 0, 0, 0, 0, 0))
    zeroAddress.sin_len = UInt8(sizeofValue(zeroAddress))
    zeroAddress.sin_family = sa_family_t(AF_INET)
    
    let defaultRouteReachability = withUnsafePointer(&zeroAddress) {
      SCNetworkReachabilityCreateWithAddress(kCFAllocatorDefault, UnsafePointer($0))
    }
    
    var flags: SCNetworkReachabilityFlags = SCNetworkReachabilityFlags(rawValue: 0)
    if SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) == false {
      return false
    }
    
    let isReachable = flags == .Reachable
    let needsConnection = flags == .ConnectionRequired
    
    return isReachable && !needsConnection
    
  }
  
  func initializeReachabilityMonitoring(){
    AFNetworkReachabilityManager.sharedManager().startMonitoring()
    
    AFNetworkReachabilityManager.sharedManager().setReachabilityStatusChangeBlock { (AFNetworkReachabilityStatus) -> Void in
      
      dispatch_async(dispatch_get_main_queue(), { () -> Void in
        switch (AFNetworkReachabilityStatus){
        case .NotReachable:
          NSNotificationCenter.defaultCenter().postNotificationName(self.kActiveNetworkError, object: self)
        case .ReachableViaWiFi:
          NSNotificationCenter.defaultCenter().postNotificationName(self.kInactiveNetworkError, object: self)
        case .ReachableViaWWAN:
          NSNotificationCenter.defaultCenter().postNotificationName(self.kInactiveNetworkError, object: self)
        case .Unknown:
          NSNotificationCenter.defaultCenter().postNotificationName(self.kActiveNetworkError, object: self)
        }
      })
    }
    
  }
}