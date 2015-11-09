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
  
  @IBOutlet weak var imageSidebarView: HSImageSidebarView!
  @IBOutlet weak var containerViewController: UIImageView!
  @IBOutlet weak var ratingLabel: UILabel!
  
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
    
    setupImageSidebar()
  }
  
  // MARK: - Initial Setup
  private func setupImageSidebar() {
    imageSidebarView.delegate = self
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

extension AMRPhotoDetailViewController: HSImageSidebarViewDelegate {
  func countOfImagesInSidebar(sidebar: HSImageSidebarView!) -> UInt {
    return UInt(photos.count)
  }
  
  func sidebar(sidebar: HSImageSidebarView!, imageForIndex anIndex: UInt) -> UIImage! {
    return photos[Int(anIndex)]
  }
}
