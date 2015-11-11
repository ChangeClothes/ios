
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
  @IBOutlet weak var thumbnailCollectionView: UICollectionView!
  @IBOutlet weak var thumbnailSelectionBoxView: UIView!
  @IBOutlet weak var ratingSegmentedControl: UISegmentedControl!
  
  
  weak var delegate: AMRPhotoDetailViewControllerDelegate?
  
  var photos = [UIImage]()
  var amrImages = [AMRImage]()
  var currentPhoto: AMRImage!
  
  // MARK: - Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    
    updateCurrentPhotoToPhoto(currentPhoto)
    
    setupRatingSegmentedControl()
    setupThumbnailCollectionView()
    setupThumbnailSelectionBox()
    dispatch_async(dispatch_get_main_queue()) { () -> Void in
      self.thumbnailCollectionView.reloadData()
    }
    dispatch_async(dispatch_get_main_queue()) { () -> Void in
      self.setInitialContentOffset()
    }
    
  }
  
  // MARK: - Utility
  // create a 1x1 image with this color
  private func imageWithColor(color: UIColor) -> UIImage {
    let rect = CGRectMake(0.0, 0.0, 1.0, 1.0)
    UIGraphicsBeginImageContext(rect.size)
    let context = UIGraphicsGetCurrentContext()
    CGContextSetFillColorWithColor(context, color.CGColor);
    CGContextFillRect(context, rect);
    let image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image
  }
  
  
  // MARK: - Initial Setup
  private func setupRatingSegmentedControl(){
    ratingSegmentedControl.setBackgroundImage(imageWithColor(UIColor.clearColor()), forState: .Normal, barMetrics: .Default)
    ratingSegmentedControl.setBackgroundImage(imageWithColor(UIColor.clearColor()), forState: .Selected, barMetrics: .Default)
    ratingSegmentedControl.setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.AMRSecondaryBackgroundColor()], forState: .Normal)
    ratingSegmentedControl.setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.AMRSelectedTabBarButtonTintColor()], forState: .Selected)
    ratingSegmentedControl.setDividerImage(imageWithColor(UIColor.clearColor()), forLeftSegmentState: .Normal, rightSegmentState: .Normal, barMetrics: .Default)
    
    ratingSegmentedControl.goVertical()
  }
  
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
  private func updateCurrentPhotoToPhoto(photo: AMRImage) {
    currentPhoto = photo
    let index = amrImages.indexOf(currentPhoto)
    containerViewController.image = photos[index!]
    switch currentPhoto.rating! {
    case .Dislike:
      ratingSegmentedControl.selectedSegmentIndex = 0
    case .Like:
      ratingSegmentedControl.selectedSegmentIndex = 1
    case .Love:
      ratingSegmentedControl.selectedSegmentIndex = 2
    case .Unrated:
      ratingSegmentedControl.selectedSegmentIndex = UISegmentedControlNoSegment
    }
  }
  
  
  // MARK: - IBActions
  @IBAction func didTapBackButton(sender: AnyObject) {
    self.delegate?.AMRPhotoDetailVIewController(self, didDismiss: true)
  }
  
  @IBAction func ratingSegmentedControlValueDidChange(sender: UISegmentedControl) {
    switch sender.selectedSegmentIndex {
    case 0:
      currentPhoto.updateRating(.Dislike, withCompletion: { () -> Void in
        self.delegate?.AMRPhotoDetailVIewController(self, didChangeToRating: .Dislike, didChangeToComment: nil)
      })
    case 1:
      currentPhoto.updateRating(.Like, withCompletion: { () -> Void in
        self.delegate?.AMRPhotoDetailVIewController(self, didChangeToRating: .Like, didChangeToComment: nil)
      })
    case 2:
      currentPhoto.updateRating(.Love, withCompletion: { () -> Void in
        self.delegate?.AMRPhotoDetailVIewController(self, didChangeToRating: .Love, didChangeToComment: nil)
      })
    default:
      print("Should never reach here")
    }

  }
}

// MARK: - UICollecitonViewDelegate
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
      updateCurrentPhotoToPhoto(amrImages[photoIndexPath.row])
    }

  }
  
  func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
    let thumbnailWidth = thumbnailCollectionView.frame.height
    let row = amrImages.indexOf(currentPhoto)
    thumbnailCollectionView.setContentOffset(CGPoint(x: CGFloat(row!)*thumbnailWidth , y: 0), animated: true)
  }
}

