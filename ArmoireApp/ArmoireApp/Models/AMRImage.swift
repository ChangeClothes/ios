//
//  AMRImage.swift
//  ArmoireApp
//
//  Created by Mathew Kellogg on 10/25/15.
//  Copyright © 2015 Armoire. All rights reserved.
//

class AMRImage: PFObject {
  
  @NSManaged var defaultImageName: String?
  @NSManaged private var file: PFFile?
  @NSManaged var client: AMRUser?
  @NSManaged var stylist: AMRUser?
  
  func setImage(image:UIImage){
    let imageData = UIImagePNGRepresentation(image)
    let imageFile = PFFile(data: imageData!)
    self.file = imageFile
    self.saveInBackground()
  }
  
  class func imagesForUser(stylist: AMRUser?, client: AMRUser?, completion: (objects: [AMRImage]?, error: NSError?) -> Void)  {
    
    let query = self.query()
    if let stylist = stylist {
      query?.whereKey("stylist", equalTo: stylist)
    }
    if let client = client {
      query?.whereKey("client", equalTo: client)
    }
    query?.findObjectsInBackgroundWithBlock({ (objects: [PFObject]?, error: NSError?) -> Void in
      completion(objects: objects as? [AMRImage], error: error)
    })
  }
  
}

extension AMRImage: PFSubclassing {
  static func parseClassName() -> String {
    return "Image"
  }
}

extension UIImageView {
  func setAMRImage(image: AMRImage?) {
    setAMRImage(image, withPlaceholder: nil)
    
  }
  
  func setAMRImage(image: AMRImage?, withPlaceholder placeholder: String?) {
    if let image = image {
      if placeholder != nil {
        self.image = UIImage(named: placeholder!)
      } else if (image.defaultImageName != nil){
        self.image = UIImage(named: image.defaultImageName!)
      } else {
        self.image = UIImage(named: "image-placeholder")
      }
      if (image.file != nil) {
        image.file!.getDataInBackgroundWithBlock { (data: NSData?, error: NSError?) -> Void in
          if error == nil {
            self.image = UIImage(data: data!)
          } else {
            print("error loading image from file")
          }
        }
      }
    } else {
      if (placeholder != nil){
        self.image = UIImage(named: placeholder!)
      } else {
        self.image = UIImage(named: "image-placeholder")
      }
    }
  }
}