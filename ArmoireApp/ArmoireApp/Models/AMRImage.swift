//
//  AMRImage.swift
//  ArmoireApp
//
//  Created by Mathew Kellogg on 10/25/15.
//  Copyright © 2015 Armoire. All rights reserved.
//

import Foundation

class AMRImage: PFObject {
    
    @NSManaged var defaultImageName: String
    @NSManaged private var file: PFFile
    @NSManaged var client: AMRUser
    @NSManaged var stylist: AMRUser
    
    func getImageView() -> UIImageView {
        let imageView = PFImageView(image: UIImage(named: defaultImageName))
        imageView.file = self.file
        imageView.loadInBackground()
        return imageView
    }
    
    func getImage(completion: (image: UIImage?, error: NSError? ) -> ()) -> UIImage {
        let image = UIImage(named:defaultImageName)
        file.getDataInBackgroundWithBlock { (data: NSData?, error: NSError?) -> Void in
            if error == nil {
                let updatedImage = UIImage(data: data!)
                completion(image: updatedImage, error: nil)
            } else {
                completion(image: nil, error: error)
            }
        }
        return image!
    }
    
    
    class func imagesForUser(stylist: AMRUser?, client: AMRUser?, completion: (objects: [AMRNote]?, error: NSError?) -> Void)  {
        
        let query = self.query()
        if let stylist = stylist {
            query?.whereKey("stylist", equalTo: stylist)
        }
        if let client = client {
            query?.whereKey("client", equalTo: client)
        }
        query?.findObjectsInBackgroundWithBlock({ (objects: [PFObject]?, error: NSError?) -> Void in
            completion(objects: objects as? [AMRNote], error: error)
        })
    }
    
}

extension AMRImage: PFSubclassing {
    static func parseClassName() -> String {
        return "Image"
    }
}