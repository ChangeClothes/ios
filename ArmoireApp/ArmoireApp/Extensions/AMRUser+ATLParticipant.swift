//
//  AMRUser+ATLParticipant.swift
//  ArmoireApp
//
//  Created by Randy Ting on 10/23/15.
//  Copyright © 2015 Armoire. All rights reserved.
//

import Foundation

extension AMRUser: ATLParticipant {
  
  var participantIdentifier: String {
    return self.objectId!
  }
  
  var avatarImageURL: NSURL? {
    return nil
  }
  
  var avatarImage: UIImage? {
    return nil
  }
  
  var avatarInitials: String {
    let initials = "\(getFirstCharacter(self.firstName))\(getFirstCharacter(self.lastName))"
    return initials.uppercaseString
  }
  
  private func getFirstCharacter(value: String) -> String {
    return (value as NSString).substringToIndex(1)
  }
}