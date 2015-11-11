
//
//  AMRPhotoDetailViewController.swift
//
//
//  Created by Mathew Kellogg on 11/1/15.
//
//

import UIKit

protocol AMRPhotoDetailViewControllerDelegate: class{
  func AMRPhotoDetailVIewController(photoViewDetailController: AMRPhotoDetailViewController, didDismiss: Bool)
  func AMRPhotoDetailVIewController(photoViewDetailController: AMRPhotoDetailViewController, didChangeToRating rating: AMRPhotoRating?, didChangeToComment comment: String? )
}

class AMRPhotoDetailViewController: UIViewController {
  
  let kThumbnailCollectionViewCellId = "com.armoire.thumbnailCollectionViewCellId"
  
  @IBOutlet weak var containerViewController: UIImageView!
  @IBOutlet weak var ratingLabel: UILabel!
  @IBOutlet weak var thumbnailCollectionView: UICollectionView!
  @IBOutlet weak var thumbnailSelectionBoxView: UIView!
  
  
  weak var delegate: AMRPhotoDetailViewControllerDelegate?
  
  var photos = [UIImage]()
  var amrImages = [AMRImage]()
  var currentPhoto: AMRImage!
  
  // MARK: - Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    
    ratingLabel.text = currentPhoto.rating?.titleForRating()
    containerViewController.setAMRImage(currentPhoto)
    let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismiss:")
    containerViewController.addGestureRecognizer(tapGestureRecognizer)
    
    setupThumbnailCollectionView()
    setupThumbnailSelectionBox()
    dispatch_async(dispatch_get_main_queue()) { () -> Void in
      self.thumbnailCollectionView.reloadData()
    }
    dispatch_async(dispatch_get_main_queue()) { () -> Void in
      self.setInitialContentOffset()
    }
    
  }
  
  
  // MARK: - Initial Setup
  private func setupThumbnailCollectionView() {
    let cellNib = UINib(nibName: "AMRPhotoDetailCollectionViewCell", bundle: nil)
    thumbnailCollectionView.registerNib(cellNib, forCellWithReuseIdentifier: kThumbnailCollectionViewCellId)
    thumbnailCollectionView.delegate = self
    thumbnailCollectionView.dataSource = self
    thumbnailCollectionView.backgroundColor = UIColor.clearColor()
    
  }
  
  private func setupThumbnailSelectionBox() {
    thumbnailSelectionBoxView.layer.borderWidth = 3.0
    thumbnailSelectionBoxView.layer.borderColor = UIColor.AMRSecondaryBackgroundColor().CGColor
  }
  
  private func setInitialContentOffset() {
    let thumbnailWidth = thumbnailCollectionView.frame.height
    let row = amrImages.indexOf(currentPhoto)
    thumbnailCollectionView.setContentOffset(CGPoint(x: CGFloat(row!)*thumbnailWidth , y: 0), animated: false)
  }
  
  // MARK: - Behavior
  func dismiss(sender: UITapGestureRecognizer){
    self.delegate?.AMRPhotoDetailVIewController(self, didDismiss: true)
  }
  
  private func updateCurrentPhotoToPhoto(photo: AMRImage) {
    currentPhoto = photo
    ratingLabel.text = currentPhoto.rating?.titleForRating()
  }
  
  
  // MARK: - IBActions
  @IBAction func dislikeButtonPressed(sender: UIButton) {
    currentPhoto.rating = .Dislike
    ratingLabel.text = currentPhoto.rating?.titleForRating()
    currentPhoto.saveInBackgroundWithBlock({ (success: Bool, error: NSError?) -> Void in
      self.delegate?.AMRPhotoDetailVIewController(self, didChangeToRating: .Dislike, didChangeToComment: nil)
    })
    
  }
  
  @IBAction func likeButtonPressed(sender: UIButton) {
    currentPhoto.rating = .Like
    ratingLabel.text = currentPhoto.rating?.titleForRating()
    currentPhoto.saveInBackgroundWithBlock({ (success: Bool, error: NSError?) -> Void in
      self.delegate?.AMRPhotoDetailVIewController(self, didChangeToRating: .Like, didChangeToComment: nil)
    })
  }
  
  @IBAction func loveButtonPressed(sender: UIButton) {
    currentPhoto.rating = .Love
    ratingLabel.text = currentPhoto.rating?.titleForRating()
    currentPhoto.saveInBackgroundWithBlock({ (success: Bool, error: NSError?) -> Void in
      self.delegate?.AMRPhotoDetailVIewController(self, didChangeToRating: .Love, didChangeToComment: nil)
    })
  }
  
}

extension AMRPhotoDetailViewController: UICollectionViewDelegate {
  
}

extension AMRPhotoDetailViewController: UICollectionViewDataSource {
  func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCellWithReuseIdentifier(kThumbnailCollectionViewCellId, forIndexPath: indexPath) as! AMRPhotoDetailCollectionViewCell
    
    cell.thumbnailImageView.image = photos[indexPath.row]
    
    return cell
  }
  
  func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return photos.count
  }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension AMRPhotoDetailViewController: UICollectionViewDelegateFlowLayout {
  func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
    let picDimension = collectionView.frame.height
    return CGSizeMake(picDimension, picDimension)
  }
  
  func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
    return UIEdgeInsetsMake(0, 0, 0, 0)
  }
  
  func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
    return 0
  }
  
  func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
    return 0
  }
  
  func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
    return CGSizeMake(collectionView.frame.width/2 - collectionView.frame.height/2, collectionView.frame.height)
  }
  
  func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
    return CGSizeMake(collectionView.frame.width/2 - collectionView.frame.height/2, collectionView.frame.height)
  }
}

// MARK: - UIScrollViewDelegate
extension AMRPhotoDetailViewController: UIScrollViewDelegate {
  func scrollViewDidScroll(scrollView: UIScrollView) {
    let collectionViewWidthCenter = thumbnailCollectionView.bounds.width/2
    let collectionViewHeightCenter = thumbnailCollectionView.bounds.height/2
    let collectionViewCenter = CGPointMake(collectionViewWidthCenter + thumbnailCollectionView.contentOffset.x,
      collectionViewHeightCenter + thumbnailCollectionView.contentOffset.y)
    
    if let photoIndexPath = thumbnailCollectionView.indexPathForItemAtPoint(collectionViewCenter) {
      containerViewController.image = photos[photoIndexPath.row]
      updateCurrentPhotoToPhoto(amrImages[photoIndexPath.row])
    }

  }
  
  func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
    let thumbnailWidth = thumbnailCollectionView.frame.height
    let row = amrImages.indexOf(currentPhoto)
    thumbnailCollectionView.setContentOffset(CGPoint(x: CGFloat(row!)*thumbnailWidth , y: 0), animated: true)
  }
}

