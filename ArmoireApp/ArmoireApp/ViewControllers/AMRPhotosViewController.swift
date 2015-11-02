//
//  AMRPhotosViewController.swift
//  ArmoireApp
//
//  Created by Mathew Kellogg on 10/27/15.
//  Copyright © 2015 Armoire. All rights reserved.
//

import UIKit

let imageCellReuseIdentifier = "cell"

class AMRPhotosViewController: AMRViewController, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, UINavigationControllerDelegate, UIImagePickerControllerDelegate, AMRViewControllerProtocol, AMRPhotoDetailViewControllerDelegate {

  
  @IBOutlet weak var collectionView: UICollectionView!
  var photos: [AMRImage] = []
  var photoPicker:PhotoPicker?
  
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
    let viewSize = self.view.frame.size
    let picDimension = viewSize.width/3.5
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
      let photo = photos[indexPath.row - 1]
      showPicture(photo)
    }
  }
  
  func AMRPhotoDetailVIewController(photoViewDetailController: AMRPhotoDetailViewController, didDismiss: Bool) {
    self.navigationController?.popViewControllerAnimated(true)
  }
  
  func showPicture(photo: AMRImage) {
    
    let popoverContent = AMRPhotoDetailViewController()
    popoverContent.delegate = self
    popoverContent.photo = photo
    
    navigationController?.pushViewController(popoverContent, animated: true)
    
  }
  
  func selectPhoto(){
    print("selecting phto")
    PhotoPicker.sharedInstance.selectPhoto(self.stylist, client: self.client, viewDelegate: self) { image in
      self.photos.append(image)
      self.collectionView.reloadData() //TOOD should I make this more efficient by just refreshing the one image?
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
  
}
