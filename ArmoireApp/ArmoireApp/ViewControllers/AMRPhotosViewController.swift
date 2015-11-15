//
//  AMRPhotosViewController.swift
//  ArmoireApp
//
//  Created by Mathew Kellogg on 10/27/15.
//  Copyright © 2015 Armoire. All rights reserved.
//

import UIKit

let uncategorizedSectionTitle = "Uncategorized"
let kImageCellReuseIdentifier = "com.armoire.imageCellReuseIdentifier"
let kItemSectionHeaderViewID = "com.armoire.photoSectionHeaderViewID"
class AMRPhotosViewController: AMRViewController {

  
  @IBOutlet weak var collectionView: UICollectionView!
  var photos: [AMRImage] = []
  var photosAsUIImage = [UIImage]()
  var photoPicker:PhotoPicker?
  var photoSections: [String: [AMRImage]]?
  
  // MARK: - Lifecycle
  override func viewDidLoad() {
    setupCollectionView()
    createNavBarButtonItems()
    title = client!.firstName + "'s Outfits"
  }
  
  override func viewWillAppear(animated: Bool) {
    //
  }
  
  // MARK: - Initial Setup
  private func setupCollectionView() {
    refreshCollectionView()
    
    collectionView.dataSource = self
    collectionView.delegate = self
    let cellNib = UINib(nibName: "imageCollectionViewCell", bundle: nil)
    collectionView.registerNib(cellNib, forCellWithReuseIdentifier: kImageCellReuseIdentifier)
    
    let sectionHeaderNib = UINib(nibName: "AMRPhotosSectionCollectionReusableView", bundle: nil)
    collectionView.registerNib(sectionHeaderNib, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: kItemSectionHeaderViewID)
    collectionView.backgroundColor = UIColor.whiteColor()
    self.view.addSubview(collectionView)
  }
  
  // MARK: - Utility
  private func sectionsForPhotosArray(images: [AMRImage]) -> [String: [AMRImage]] {
    var photoSections = [String: [AMRImage]]()
    
    for image in images {
      
      if image.rating == nil {
        image.rating = AMRPhotoRating.Unrated
      }
      
      if photoSections[image.rating!.titleForRating()] == nil{
        photoSections[image.rating!.titleForRating()] = [AMRImage]()
      }
      photoSections[image.rating!.titleForRating()]!.append(image)
    }
    return photoSections
  }
  
  private func refreshCollectionView() {
    AMRImage.imagesForUser(stylist, client: client) { (objects, error) -> Void in
      self.photos = objects! as [AMRImage]

      self.photoSections = self.sectionsForPhotosArray(self.photos)
      self.uiImageArrayFromAMRImageArray(self.amrImageArrayFromPhotoSections(self.photoSections!))
      self.collectionView.reloadData()
    }
  }
  
  private func uiImageArrayFromAMRImageArray(array: [AMRImage]){
    let arrayCount = array.count
    photosAsUIImage = [UIImage](count: arrayCount, repeatedValue: UIImage())
    
    for (index,image) in array.enumerate() {
      image.getImage({ (correctImage: UIImage) -> () in
        self.photosAsUIImage[index] = correctImage
      })
    }
  }
  
  private func amrImageArrayFromPhotoSections(sections:[String: [AMRImage]]) -> [AMRImage] {
    var resultArray = [AMRImage]()

    for rating in AMRPhotoRating.titleArray() {
      if let array = sections[rating] {
        resultArray.appendContentsOf(array)
      }
    }
    
    return resultArray
  }
}

// MARK: UICollectionViewDataSource
extension AMRPhotosViewController: UICollectionViewDataSource{
  
  func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
    return AMRPhotoRating.titleArray().count
  }
  
  func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    if let sections = photoSections {
      if let imagesArray = sections[AMRPhotoRating.titleArray()[section]] {
        if section == 0 {
          return imagesArray.count// + 1 // For camera button
        } else {
          return imagesArray.count
        }
        
      }
    }
    if section == 0 {
      //return 1  // For camera button
    }
    return 0
  }
  
  func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
    return CGSizeMake(60.0, 30.0)
  }
  
  func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
    let view = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: kItemSectionHeaderViewID, forIndexPath: indexPath) as! AMRPhotosSectionCollectionReusableView

    view.sectionTitleLabel.text = AMRPhotoRating.titleArray()[indexPath.section]
    view.sectionTitleLabel.textColor = AMRPhotoRating.iconColorArray()[indexPath.section]
    view.ratingIconImageView.tintColor = AMRPhotoRating.iconColorArray()[indexPath.section]
    view.ratingIconImageView.image = AMRPhotoRating.ratingIconArray()[indexPath.section]
    
    return view
  }
  
  func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    
    let cell = collectionView.dequeueReusableCellWithReuseIdentifier(kImageCellReuseIdentifier, forIndexPath: indexPath) as! imageCollectionViewCell
    
    /*if indexPath.row == 0 && indexPath.section == 0{
      cell.activityIndicatorView.stopAnimating()
      let addPhotoIcon = UIImage(named: "add-photo")
      cell.imageView.image = addPhotoIcon
      //cell.imageView.layer.borderColor = UIColor.whiteColor().CGColor
      //cell.imageView.layer.borderWidth = 7.0
      //cell.imageView.layer.cornerRadius = 8
      cell.imageView.contentMode = .ScaleAspectFit
      cell.backgroundColor = UIColor.clearColor()
    } else if indexPath.section == 0 {
      cell.activityIndicatorView.startAnimating()
      let image = photoSections![AMRPhotoRating.titleArray()[indexPath.section]]![indexPath.row]// - 1]
      cell.imageView.setAMRImage(image, withPlaceholder: "download", withCompletion: { (success) -> Void in
        cell.activityIndicatorView.stopAnimating()
      })
      
    } else {*/
      cell.activityIndicatorView.startAnimating()
      let image = photoSections![AMRPhotoRating.titleArray()[indexPath.section]]![indexPath.row]
      cell.imageView.setAMRImage(image, withPlaceholder: "download", withCompletion: { (success) -> Void in
        cell.activityIndicatorView.stopAnimating()
      })
      
    //}
    return cell
  }
  
}

// MARK: - UICollectionViewDelegate
extension AMRPhotosViewController: UICollectionViewDelegate {
  func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    collectionView.deselectItemAtIndexPath(indexPath, animated: true)
    
    if indexPath.row == 0 && indexPath.section == 0 {
      selectPhoto()
    } else if indexPath.section == 0 {
      let photo = photoSections![AMRPhotoRating.titleArray()[indexPath.section]]![indexPath.row - 1]
      showPicture(photo)
    } else {
      let photo = photoSections![AMRPhotoRating.titleArray()[indexPath.section]]![indexPath.row]
      showPicture(photo)
    }
  }
  
  // MARK: - Utility
  func showPicture(photo: AMRImage) {
    
    let popoverContent = AMRPhotoDetailViewController()
    popoverContent.delegate = self
    
    popoverContent.currentPhoto = photo
    
    let amrImages = amrImageArrayFromPhotoSections(photoSections!)
    popoverContent.amrImages = amrImages
    popoverContent.photos = self.photosAsUIImage
    
    navigationController?.pushViewController(popoverContent, animated: true)
  }
  
  func selectPhoto(){
    PhotoPicker.sharedInstance.selectPhoto(self.stylist, client: self.client, viewDelegate: self) { image in
      self.photos.append(image)
      self.refreshCollectionView() //TOOD should I make this more efficient by just refreshing the one image?
    }
  }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension AMRPhotosViewController: UICollectionViewDelegateFlowLayout {
  func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
    let viewSize = self.view.frame.size
    let picDimension = viewSize.width/4.0
    return CGSizeMake(picDimension, picDimension)
  }
  
  func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
    return UIEdgeInsetsMake(10.0, 0, 10.0, 0)
  }
  
  func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
    return 0.0
  }
  
  func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
    return 10.0
  }
}

extension AMRPhotosViewController: AMRPhotoDetailViewControllerDelegate {
  func AMRPhotoDetailVIewController(photoViewDetailController: AMRPhotoDetailViewController, didDismiss: Bool) {
    self.navigationController?.popViewControllerAnimated(true)
  }
  
  func AMRPhotoDetailVIewController(photoViewDetailController: AMRPhotoDetailViewController, didChangeToRating rating: AMRPhotoRating?, didChangeToComment comment: String? ){
    refreshCollectionView()
  }
}

// MARK: - Create Nav Bar Button Items
extension AMRPhotosViewController {
  private func createNavBarButtonItems(){
    if (stylist != nil && client != nil){
      createExitModalButton()
    } else {
      createSettingsButton()
    }
    createCameraButton()
  }
  
  private func createDoneEditingButton(){
    let doneButton: UIButton = UIButton()
    doneButton.setImage(UIImage(named: "check"), forState: .Normal)
    
    doneButton.frame = CGRectMake(0, 0, 30, 30)
    doneButton.addTarget(self, action: Selector("onDoneEditingTap"), forControlEvents: .TouchUpInside)
    
    let rightNavBarButton = UIBarButtonItem(customView: doneButton)
    self.navigationItem.rightBarButtonItem = rightNavBarButton
  }
  
  private func createCameraButton() {
    let rightNavBarButton = UIBarButtonItem(image: UIImage(named: "camera"), style: .Plain, target: self, action: "selectPhoto")
    self.navigationItem.rightBarButtonItem = rightNavBarButton
  }
  
  private func createExitModalButton(){
    let leftNavBarButton = UIBarButtonItem(image: UIImage(named: "cancel"), style: .Plain, target: self, action: "exitModal")
    self.navigationItem.leftBarButtonItem = leftNavBarButton
  }
  
  private func createSettingsButton(){
    let leftNavBarButton = UIBarButtonItem(image: UIImage(named: "settings"), style: .Plain, target: self, action: "onSettingsTap")
    self.navigationItem.leftBarButtonItem = leftNavBarButton
  }
  
  // MARK: - On Tap Actions
  
  func exitModal(){
    NSNotificationCenter.defaultCenter().postNotificationName(kDismissedModalNotification, object: self)
    self.dismissViewControllerAnimated(true, completion: nil)
  }
  
  func onSettingsTap(){
    let settingsVC = UIAlertController.AMRSettingsController { (AMRSettingsControllerSetting) -> () in}
    self.presentViewController(settingsVC, animated: true, completion: nil)
  }


}

