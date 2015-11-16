//
//  AMRProfileImage.swift
//  ArmoireApp
//
//  Created by Randy Ting on 11/15/15.
//  Copyright © 2015 Armoire. All rights reserved.
//

import UIKit

class AMRProfileImage: NSObject {
  
  static let cache = AMRProfileImage()
  
  var profileImages = [String:UIImage]()
  
  func cacheProfileImagesForClients(clients: [AMRUser]) {
    for client in clients {
      getImageForClient(client)
    }
  }
  
  private func getImageForClient(client: AMRUser) {
    let objId = client.objectId!
    client.profilePhoto?.fetchIfNeededInBackgroundWithBlock({ (photo: PFObject?, error: NSError?) -> Void in
      if let error = error {
        print(error.localizedDescription)
      } else {
        let profilePic = photo as! AMRImage
        profilePic.getImage({ (image: UIImage) -> () in
          self.profileImages[objId] = image
        })
      }
    })
  }
  
}
