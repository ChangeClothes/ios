//
//  AMRPhotosViewController.swift
//  ArmoireApp
//
//  Created by Mathew Kellogg on 10/27/15.
//  Copyright © 2015 Armoire. All rights reserved.
//

import UIKit

let imageCellReuseIdentifier = "cell"

class AMRPhotosViewController: UIViewController, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, UINavigationControllerDelegate, UIImagePickerControllerDelegate, AMRViewControllerProtocol{

  
  @IBOutlet weak var collectionView: UICollectionView!
  var stylist: AMRUser?
  var client: AMRUser?
  var photos: [AMRImage] = []
  
  func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
      return photos.count + 1
  }
  
  func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    
    let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) as! imageCollectionViewCell
    if indexPath.row == 0 {
      cell.imageView.image = UIImage(named: "add-photo")
    } else {
      let image = photos[indexPath.row - 1]
      cell.imageView.setAMRImage(image)
    }
    return cell
  }
  
  
  override func viewDidLoad() {
    AMRImage.imagesForUser(stylist, client: client) { (objects, error) -> Void in
      self.photos = objects! as [AMRImage]
      self.collectionView.reloadData()
    }
    
    self.navigationController?.setNavigationBarHidden(true, animated: false)
    
    collectionView.dataSource = self
    collectionView.delegate = self
    collectionView.registerClass(imageCollectionViewCell.self, forCellWithReuseIdentifier: "Cell")
    collectionView.backgroundColor = UIColor.whiteColor()
    self.view.addSubview(collectionView)
    
    
  }
  
  func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
    let picDimension = (self.view.frame.size.width / 3.17)
    return CGSizeMake(picDimension, picDimension)
  }
  
  func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
    //let leftRightInset = self.view.frame.size.width / 14.0
    return UIEdgeInsetsMake(0, 0, 0, 0)
  }
  
  func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    collectionView.deselectItemAtIndexPath(indexPath, animated: true)
    
    if indexPath.row == 0 {
      selectPhoto()
    } else {
      //TODO show modal view with picture
    }
  }

  
  internal func setVcData(stylist: AMRUser?, client: AMRUser?) {
    self.stylist = stylist
    self.client = client
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  /******************
   *** PHOTO LOGIC ***
   ******************/
  var photoVC: UIImagePickerController? = nil
  var pickerVC:UIImagePickerController?=UIImagePickerController()
  
  func open(sourceType: UIImagePickerControllerSourceType) {
    photoVC = UIImagePickerController()
    photoVC!.delegate = self
    photoVC!.allowsEditing = true
    photoVC!.sourceType = sourceType
    self.presentViewController(photoVC!, animated: true, completion: nil)
  }
  
  func selectPhoto(){
    
    let alert:UIAlertController=UIAlertController(title: "Choose Image", message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
    pickerVC?.delegate = self
    
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
      
      imagePicked(storedImage)
      
      //dismiss view controller
      self.photoVC?.dismissViewControllerAnimated(true, completion: { () -> Void in
        self.photoVC = nil
      })
      
  }
  
  func imagePicked(image:AMRImage){
    self.photos.append(image)
    self.collectionView.reloadData() //TOOD should I make this more efficient by just refreshing the one image?
    print("imagePicked")
  }
  
  //END PHOTO LOGIC
  
}
