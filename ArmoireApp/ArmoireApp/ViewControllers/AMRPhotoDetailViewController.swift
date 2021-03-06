
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
  
  @IBOutlet weak var photoImageView: UIImageView!
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
    
    setupRatingSegmentedControl()
    updateCurrentPhotoToPhoto(currentPhoto)
    setupThumbnailCollectionView()
    setupThumbnailSelectionBox()
    setupPhotoImageView()
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
  }
  
  private func setupPhotoImageView(){
    let swipeRightGR = UISwipeGestureRecognizer(target: self, action: "didSwipePhoto:")
    swipeRightGR.direction = .Right
    photoImageView.addGestureRecognizer(swipeRightGR)
    let swipeLeftGR = UISwipeGestureRecognizer(target: self, action: "didSwipePhoto:")
    swipeLeftGR.direction = .Left
    photoImageView.addGestureRecognizer(swipeLeftGR)
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
    photoImageView.image = photos[row!]
  }
  
  // MARK: - Behavior
  func didSwipePhoto(sender: UISwipeGestureRecognizer) {
    switch sender.direction {
    case UISwipeGestureRecognizerDirection.Right:
      if let index = amrImages.indexOf(currentPhoto) where index == 0 {
        // Do nothing
      } else {
        
        currentPhoto = amrImages[amrImages.indexOf(currentPhoto)! - 1]
      }
    case UISwipeGestureRecognizerDirection.Left:
      if let index = amrImages.indexOf(currentPhoto) where index == amrImages.count - 1 {
        // Do nothing
      } else {
        currentPhoto = amrImages[amrImages.indexOf(currentPhoto)! + 1]
      }
    default:
      print("Shouldn't be able to reach here")
    }
    changeThumbnailPhotoToCurrentPhoto()
  }
  
  private func updateCurrentPhotoToPhoto(photo: AMRImage) {
    currentPhoto = photo
    switch currentPhoto.rating! {
    case .Nope:
      ratingSegmentedControl.selectedSegmentIndex = 2
      highlightSegment(2, inSegmentedControl: ratingSegmentedControl)
    case .Maybe:
      ratingSegmentedControl.selectedSegmentIndex = 1
      highlightSegment(1, inSegmentedControl: ratingSegmentedControl)
    case .Yep:
      ratingSegmentedControl.selectedSegmentIndex = 0
      highlightSegment(0, inSegmentedControl: ratingSegmentedControl)
    case .Unrated:
      ratingSegmentedControl.selectedSegmentIndex = UISegmentedControlNoSegment
      highlightSegment(-1, inSegmentedControl: ratingSegmentedControl)
    }
    
  }
  
  private func changeThumbnailPhotoToCurrentPhoto() {
    let thumbnailWidth = thumbnailCollectionView.frame.height
    let row = amrImages.indexOf(currentPhoto)
    thumbnailCollectionView.setContentOffset(CGPoint(x: CGFloat(row!)*thumbnailWidth , y: 0), animated: true)
  }
  
  // MARK: - IBActions
  @IBAction func ratingSegmentedControlValueDidChange(sender: UISegmentedControl) {
    switch sender.selectedSegmentIndex {
    case 0:
      currentPhoto.updateRating(.Yep, withCompletion: { () -> Void in
        self.delegate?.AMRPhotoDetailVIewController(self, didChangeToRating: .Yep, didChangeToComment: nil)
      })
    case 1:
      currentPhoto.updateRating(.Maybe, withCompletion: { () -> Void in
        self.delegate?.AMRPhotoDetailVIewController(self, didChangeToRating: .Maybe, didChangeToComment: nil)
      })
    case 2:
      currentPhoto.updateRating(.Nope, withCompletion: { () -> Void in
        self.delegate?.AMRPhotoDetailVIewController(self, didChangeToRating: .Nope, didChangeToComment: nil)
      })
    default:
      print("Should never reach here")
    }
    highlightSegment(sender.selectedSegmentIndex, inSegmentedControl: sender)
    
  }
  
  private func highlightSegment(segment: Int, inSegmentedControl sender: UISegmentedControl) {
    let segmentWidth = sender.frame.width/CGFloat(sender.numberOfSegments)
    let selectedSegmentHeight = sender.frame.width - (CGFloat(sender.numberOfSegments-1-sender.selectedSegmentIndex)+0.5)*segmentWidth
    
    for subview in sender.subviews{
      subview.tintColor = ThemeManager.currentTheme().unselectedRatingIconColor
      let centerHeight = subview.center.x
      if abs(round(selectedSegmentHeight) - round(centerHeight)) <= 1 {
        switch sender.selectedSegmentIndex {
        case 0:
          subview.tintColor = ThemeManager.currentTheme().likeIconColor
        case 1:
          subview.tintColor = ThemeManager.currentTheme().neutralIconColor
        case 2:
          subview.tintColor = ThemeManager.currentTheme().dislikeIconColor
        default:
          print("Shouldn't reach here")
        }
      }
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
  
  func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    currentPhoto = amrImages[indexPath.row]
    changeThumbnailPhotoToCurrentPhoto()
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
      photoImageView.image = photos[photoIndexPath.row]
    }

  }
  
  func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
    changeThumbnailPhotoToCurrentPhoto()
  }
}

