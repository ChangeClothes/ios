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
  var photosAsUIImage: [UIImage] = []
  var photoPicker:PhotoPicker?
  var photoSections: [String: [AMRImage]]?
  
  // MARK: - Lifecycle
  override func viewDidLoad() {
    setupCollectionView()
    self.navigationController?.setNavigationBarHidden(true, animated: false)
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
      self.uiImageArrayFromAMRImageArray(self.photos)
      self.photoSections = self.sectionsForPhotosArray(self.photos)
      self.collectionView.reloadData()
    }
  }
  
  private func uiImageArrayFromAMRImageArray(array: [AMRImage]) {
    let arrayCount = array.count
    photosAsUIImage = [UIImage](count: arrayCount, repeatedValue: UIImage())
    
    for (index,image) in array.enumerate() {
      image.getImage({ (correctImage: UIImage) -> () in
        self.photosAsUIImage[index] = correctImage
      })
    }

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
          return imagesArray.count + 1 // For camera button
        } else {
          return imagesArray.count
        }
        
      }
    }
    if section == 0 {
      return 1  // For camera button
    }
    return 0
  }
  
  func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
    return CGSizeMake(60.0, 30.0)
  }
  
  func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
    let view = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: kItemSectionHeaderViewID, forIndexPath: indexPath) as! AMRPhotosSectionCollectionReusableView

    view.sectionTitleLabel.text = AMRPhotoRating.titleArray()[indexPath.section]
    
    return view
  }
  
  func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    
    let cell = collectionView.dequeueReusableCellWithReuseIdentifier(kImageCellReuseIdentifier, forIndexPath: indexPath) as! imageCollectionViewCell
    
    if indexPath.row == 0 && indexPath.section == 0{
      cell.activityIndicatorView.stopAnimating()
      var cameraIcon = UIImage(named: "camera-add")
      cameraIcon = cameraIcon?.imageWithRenderingMode(.AlwaysTemplate)
      cell.imageView.tintColor = UIColor.AMRSecondaryBackgroundColor()
      cell.imageView.image = cameraIcon
    } else if indexPath.section == 0 {
      cell.activityIndicatorView.startAnimating()
      let image = photoSections![AMRPhotoRating.titleArray()[indexPath.section]]![indexPath.row - 1]
      cell.imageView.backgroundColor = UIColor.grayColor()
      cell.imageView.setAMRImage(image, withPlaceholder: "download", withCompletion: { (success) -> Void in
        cell.activityIndicatorView.stopAnimating()
      })
      
    } else {
      cell.activityIndicatorView.startAnimating()
      let image = photoSections![AMRPhotoRating.titleArray()[indexPath.section]]![indexPath.row]
      cell.imageView.backgroundColor = UIColor.grayColor()
      cell.imageView.setAMRImage(image, withPlaceholder: "download", withCompletion: { (success) -> Void in
        cell.activityIndicatorView.stopAnimating()
      })
      
    }
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
    
    popoverContent.photo = photo
    popoverContent.amrImages = photos
    popoverContent.photos = photosAsUIImage
    
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
    let picDimension = viewSize.width/3.5
    return CGSizeMake(picDimension, picDimension)
  }
  
  func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
    return UIEdgeInsetsMake(15.0, 0, 15.0, 0)
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

