//
//  AMRClientProfileViewController.swift
//  ArmoireApp
//
//  Created by Morgan Wildermuth on 10/26/15.
//  Copyright © 2015 Armoire. All rights reserved.
//

import UIKit

class AMRClientProfileViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIAlertViewDelegate, AMRViewControllerProtocol{


  @IBOutlet weak var myImage: UIImageView!
  
  /*******************************
   *** AMRViewController LOGIC ***
   ******************************/
  var stylist: AMRUser?
  var client: AMRUser?
  
  func setVcData(stylist: AMRUser?, client: AMRUser?) {
    self.stylist = stylist
    self.client = client
    loadProfile()
  }
  
  /******************
  *** PHOTO LOGIC ***
  ******************/
  var photoVC: UIImagePickerController? = nil
  var pickerVC:UIImagePickerController?=UIImagePickerController()
  
  func openCamera() {
    photoVC = UIImagePickerController()
    photoVC!.delegate = self
    photoVC!.allowsEditing = true
    photoVC!.sourceType = UIImagePickerControllerSourceType.Camera
    self.presentViewController(photoVC!, animated: true, completion: nil)
  }
  
  func openGallery() {
    photoVC = UIImagePickerController()
    photoVC!.delegate = self
    photoVC!.allowsEditing = true
    photoVC!.sourceType = UIImagePickerControllerSourceType.SavedPhotosAlbum
    self.presentViewController(photoVC!, animated: true, completion: nil)
  }
  
  func selectPhoto(){
    
    let alert:UIAlertController=UIAlertController(title: "Choose Image", message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
    pickerVC?.delegate = self
    
    let cameraAction = UIAlertAction(title: "Take Photo", style: UIAlertActionStyle.Default)
      {
        UIAlertAction in
        self.openCamera()
        
    }
    let galleryAction = UIAlertAction(title: "Select Photo", style: UIAlertActionStyle.Default){
      UIAlertAction in
      self.openGallery()
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

    self.presentViewController(alert, animated: true, completion: nil)

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
      
      //dismiss view controller
      self.photoVC?.dismissViewControllerAnimated(true, completion: { () -> Void in
        self.photoVC = nil
      })
      
  }
  //END PHOTO LOGIC
  
  func loadProfile(){
    
  }
  
  @IBAction func onTap(sender: AnyObject) {
    selectPhoto()
    
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()

    // Do any additional setup after loading the view.
      

  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
}
