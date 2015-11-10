
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
  
  weak var delegate: AMRPhotoDetailViewControllerDelegate?
  
  var photos = [UIImage]()
  var photo: AMRImage?
  
  // MARK: - Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    
    ratingLabel.text = photo?.rating?.titleForRating()
    containerViewController.setAMRImage(photo!)
    let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismiss:")
    containerViewController.addGestureRecognizer(tapGestureRecognizer)
    
    setupThumbnailCollectionView()
    
  }
  
  // MARK: - Initial Setup
  private func setupThumbnailCollectionView() {
    let cellNib = UINib(nibName: "AMRPhotoDetailCollectionViewCell", bundle: nil)
    thumbnailCollectionView.registerNib(cellNib, forCellWithReuseIdentifier: kThumbnailCollectionViewCellId)
    thumbnailCollectionView.delegate = self
    thumbnailCollectionView.dataSource = self
  }

  // MARK: - Behavior
  func dismiss(sender: UITapGestureRecognizer){
    self.delegate?.AMRPhotoDetailVIewController(self, didDismiss: true)
  }
  
  
  // MARK: - IBActions
  @IBAction func dislikeButtonPressed(sender: UIButton) {
    photo?.rating = .Dislike
    ratingLabel.text = photo?.rating?.titleForRating()
    photo?.saveInBackgroundWithBlock({ (success: Bool, error: NSError?) -> Void in
      self.delegate?.AMRPhotoDetailVIewController(self, didChangeToRating: .Dislike, didChangeToComment: nil)
    })
    
  }
  
  @IBAction func likeButtonPressed(sender: UIButton) {
    photo?.rating = .Like
    ratingLabel.text = photo?.rating?.titleForRating()
    photo?.saveInBackgroundWithBlock({ (success: Bool, error: NSError?) -> Void in
      self.delegate?.AMRPhotoDetailVIewController(self, didChangeToRating: .Like, didChangeToComment: nil)
    })
  }
  
  @IBAction func loveButtonPressed(sender: UIButton) {
    photo?.rating = .Love
    ratingLabel.text = photo?.rating?.titleForRating()
    photo?.saveInBackgroundWithBlock({ (success: Bool, error: NSError?) -> Void in
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
    return CGSizeMake(collectionView.frame.width/2, collectionView.frame.height)
  }
  
  func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
    return CGSizeMake(collectionView.frame.width/2, collectionView.frame.height)
  }
}

