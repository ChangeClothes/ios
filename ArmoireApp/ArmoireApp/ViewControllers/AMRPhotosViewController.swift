//
//  AMRPhotosViewController.swift
//  ArmoireApp
//
//  Created by Mathew Kellogg on 10/27/15.
//  Copyright © 2015 Armoire. All rights reserved.
//

import UIKit

let uncategorizedSectionTitle = "Uncategorized"
let imageCellReuseIdentifier = "cell"
class AMRPhotosViewController: AMRViewController {

  
  @IBOutlet weak var collectionView: UICollectionView!
  var photos: [AMRImage] = []
  var photoPicker:PhotoPicker?
  var photoSections: [String: [AMRImage]]?
  
  // MARK: - Lifecycle
  override func viewDidLoad() {
    setupCollectionView()
    
    self.navigationController?.setNavigationBarHidden(true, animated: false)
  }
  
  // MARK: - Initial Setup
  private func setupCollectionView() {
    AMRImage.imagesForUser(stylist, client: client) { (objects, error) -> Void in
      self.photos = objects! as [AMRImage]
      self.photoSections = self.sectionsForPhotosArray(self.photos)
      self.collectionView.reloadData()
    }
    
    collectionView.dataSource = self
    collectionView.delegate = self
    let cellNib = UINib(nibName: "imageCollectionViewCell", bundle: nil)
    collectionView.registerNib(cellNib, forCellWithReuseIdentifier: "Cell")
    collectionView.backgroundColor = UIColor.whiteColor()
    self.view.addSubview(collectionView)
  }
  
  // MARK: - Utility
  private func sectionsForPhotosArray(images: [AMRImage]) -> [String: [AMRImage]] {
    var photoSections = [String: [AMRImage]]()
    
    for image in images {
      if let rating = image.rating {
        guard let _ = photoSections[rating.titleForRating()] else {
          photoSections[rating.titleForRating()] = [AMRImage]()
          break
        }
        photoSections[rating.titleForRating()]?.append(image)
  
      } else {
        if photoSections[uncategorizedSectionTitle] == nil {
          photoSections[uncategorizedSectionTitle] = [AMRImage]()
        }
        photoSections[uncategorizedSectionTitle]?.append(image)
      }
    }
    return photoSections
  }
}

// MARK: UICollectionViewDataSource
extension AMRPhotosViewController: UICollectionViewDataSource{
  func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return photos.count + 1
  }
  
  func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    
    let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) as! imageCollectionViewCell
    
    if indexPath.row == 0 {
      cell.activityIndicatorView.stopAnimating()
      var cameraIcon = UIImage(named: "camera-add")
      cameraIcon = cameraIcon?.imageWithRenderingMode(.AlwaysTemplate)
      cell.imageView.tintColor = UIColor.AMRSecondaryBackgroundColor()
      cell.imageView.image = cameraIcon
    } else {
      cell.activityIndicatorView.startAnimating()
      let image = photos[indexPath.row - 1]
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
    
    if indexPath.row == 0 {
      selectPhoto()
    } else {
      let photo = photos[indexPath.row - 1]
      showPicture(photo)
    }
  }
  
  // MARK: - Utility
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
}

// MARK: - UICollectionViewDelegateFlowLayout
extension AMRPhotosViewController: UICollectionViewDelegateFlowLayout {
  func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
    let viewSize = self.view.frame.size
    let picDimension = viewSize.width/3.5
    return CGSizeMake(picDimension, picDimension)
  }
  
  func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
    //let leftRightInset = self.view.frame.size.width / 14.0
    return UIEdgeInsetsMake(0, 0, 0, 0)
  }
}

extension AMRPhotosViewController: AMRPhotoDetailViewControllerDelegate {
  func AMRPhotoDetailVIewController(photoViewDetailController: AMRPhotoDetailViewController, didDismiss: Bool) {
    self.navigationController?.popViewControllerAnimated(true)
  }
}

