//
//  AMRImage.swift
//  ArmoireApp
//
//  Created by Mathew Kellogg on 10/25/15.
//  Copyright © 2015 Armoire. All rights reserved.
//

class AMRImage: PFObject {
  
  @NSManaged var defaultImageName: String?
  @NSManaged var file: PFFile?
  @NSManaged var client: AMRUser?
  @NSManaged var stylist: AMRUser?
  
  func getData() -> NSData?{
    do {
      return try file?.getData()
    } catch {
      return NSData()
    }
  }
  
  func setImage(image:UIImage){
    let imageData = UIImagePNGRepresentation(image)
    let imageFile = PFFile(data: imageData!)
    self.file = imageFile
    self.saveInBackground()
  }
  
  func getImage(completion: (UIImage)-> ()){
    self.file?.getDataInBackgroundWithBlock({ (data, error) -> Void in
      if error == nil {
        completion(UIImage(data: data!)!)
      } else {
        print("error loading image from file")
      }
    })
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
  
  class func queryForObjectWithObjectID(objectID: String, withCompletion completion: ((NSArray?, NSError?) -> Void)?) {
    let query: PFQuery! = AMRImage.query()
    query.whereKey("objectId", equalTo: objectID)
    query.findObjectsInBackgroundWithBlock { objects, error in
      if let callback = completion {
        callback(objects, error)
      }
    }
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
  
  func setAMRImage(imageParam: AMRImage?, withPlaceholder placeholder: String?) {
    if let myImage = imageParam {
      if placeholder != nil {
        self.image = UIImage(named: placeholder!)
      } else if (myImage.defaultImageName != nil){
        self.image = UIImage(named: myImage.defaultImageName!)
      } else {
        self.image = UIImage(named: "image-placeholder")
      }
      myImage.file?.getDataInBackgroundWithBlock { (data: NSData?, error: NSError?) -> Void in
        if error == nil {
          self.image = UIImage(data: data!)
        } else {
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


class PhotoPicker: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
  
  static let sharedInstance = PhotoPicker()
  
  func selectPhoto(stylist: AMRUser?, client: AMRUser?, viewDelegate:UIViewController?, completion: ((AMRImage) -> ())? ){
    
    self.stylist = stylist
    self.client = client
    self.viewDelegate = viewDelegate
    self.complete = completion
    self.selectPhotoSource()
  }
  
  var stylist: AMRUser?
  var client: AMRUser?
  weak var viewDelegate: UIViewController?
  var complete: ((AMRImage) -> ())?
  
  var photoVC: UIImagePickerController? = nil
  
  private func open(sourceType: UIImagePickerControllerSourceType) {
    photoVC = UIImagePickerController()
    photoVC!.delegate = self
    photoVC!.allowsEditing = true
    photoVC!.sourceType = sourceType
    viewDelegate?.presentViewController(photoVC!, animated: true, completion: nil)
  }
  
  private func selectPhotoSource(){
    
    let alert:UIAlertController=UIAlertController(title: "Choose Image", message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
    
    let cameraAction = UIAlertAction(title: "Take Photo", style: UIAlertActionStyle.Default)
      {
        UIAlertAction in
        self.open(UIImagePickerControllerSourceType.Camera)
    }
    let galleryAction = UIAlertAction(title: "Select Photo", style: UIAlertActionStyle.Default){
      UIAlertAction in
      self.open(UIImagePickerControllerSourceType.SavedPhotosAlbum)
    }
    let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel) {
      UIAlertAction in
    }
    // Add the actions
    if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera){
      alert.addAction(cameraAction)
      
    }
    if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.SavedPhotosAlbum) {
      alert.addAction(galleryAction)
    }
    alert.addAction(cancelAction)
    
    viewDelegate?.presentViewController(alert, animated: true, completion: nil)
    
  }
  
  func imagePickerController(picker: UIImagePickerController,
    didFinishPickingMediaWithInfo info: [String : AnyObject]) {
      let originalImage = info[UIImagePickerControllerOriginalImage] as? UIImage
      let editedImage = info[UIImagePickerControllerEditedImage] as? UIImage
      
      var image: UIImage? = nil
      if (editedImage != nil) {
        image = editedImage
      } else if originalImage != nil {
        image = originalImage
      } else {
        // prolly won't happen. what should we do here?
      }
      
      let storedImage = AMRImage()
      storedImage.stylist = self.stylist
      storedImage.client = self.client
      storedImage.setImage(image!)
      
      self.complete!(storedImage)
      
      //dismiss view controller
      self.photoVC?.dismissViewControllerAnimated(true, completion: { () -> Void in
        self.photoVC = nil
      })
      
  }
  
}


extension UIImage{
  
  class func roundedRectImageFromImage(image:UIImage,imageSize:CGSize,cornerRadius:CGFloat)->UIImage{
    UIGraphicsBeginImageContextWithOptions(imageSize,false,0.0)
    let bounds=CGRect(origin: CGPointZero, size: imageSize)
    UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius).addClip()
    image.drawInRect(bounds)
    let finalImage=UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return finalImage
  }
  
}

//TODO - put this code somewhere else...
func AMRSquareImageTo(image: UIImage, size: CGSize) -> UIImage {
  return AMRResizeImage(AMRSquareImage(image), targetSize: size)
}

func AMRSquareImage(image: UIImage) -> UIImage {
  let originalWidth  = image.size.width
  let originalHeight = image.size.height
  
  var edge: CGFloat
  if originalWidth > originalHeight {
    edge = originalHeight
  } else {
    edge = originalWidth
  }
  
  let posX = (originalWidth  - edge) / 2.0
  let posY = (originalHeight - edge) / 2.0
  
  let cropSquare = CGRectMake(posX, posY, edge, edge)
  
  let imageRef = CGImageCreateWithImageInRect(image.CGImage, cropSquare);
  return UIImage(CGImage: imageRef!, scale: UIScreen.mainScreen().scale, orientation: image.imageOrientation)
}

func AMRResizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
  let size = image.size
  
  let widthRatio  = targetSize.width  / image.size.width
  let heightRatio = targetSize.height / image.size.height
  
  // Figure out what our orientation is, and use that to form the rectangle
  var newSize: CGSize
  if(widthRatio > heightRatio) {
    newSize = CGSizeMake(size.width * heightRatio, size.height * heightRatio)
  } else {
    newSize = CGSizeMake(size.width * widthRatio,  size.height * widthRatio)
  }
  
  // This is the rect that we've calculated out and this is what is actually used below
  let rect = CGRectMake(0, 0, newSize.width, newSize.height)
  
  // Actually do the resizing to the rect using the ImageContext stuff
  UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
  image.drawInRect(rect)
  let newImage = UIGraphicsGetImageFromCurrentImageContext()
  UIGraphicsEndImageContext()
  
  return newImage
}