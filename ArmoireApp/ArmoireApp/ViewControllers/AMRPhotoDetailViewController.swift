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
}

class AMRPhotoDetailViewController: UIViewController {
  
  @IBOutlet weak var containerViewController: UIImageView!
  @IBOutlet weak var ratingLabel: UILabel!
  
  weak var delegate: AMRPhotoDetailViewControllerDelegate?
  
  var photo: AMRImage?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    
    ratingLabel.text = photo?.rating?.titleForRating()
    containerViewController.setAMRImage(photo!)
    let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismiss:")
    containerViewController.addGestureRecognizer(tapGestureRecognizer)
  }
  
  func dismiss(sender: UITapGestureRecognizer){
    self.delegate?.AMRPhotoDetailVIewController(self, didDismiss: true)
  }
  
  @IBAction func dislikeButtonPressed(sender: UIButton) {
    photo?.rating = AMRImage.AMRPhotoRating.Dislike
    ratingLabel.text = photo?.rating?.titleForRating()
  }
  
  @IBAction func likeButtonPressed(sender: UIButton) {
    photo?.rating = AMRImage.AMRPhotoRating.Like
    ratingLabel.text = photo?.rating?.titleForRating()
  }
  
  @IBAction func loveButtonPressed(sender: UIButton) {
    photo?.rating = AMRImage.AMRPhotoRating.Love
    ratingLabel.text = photo?.rating?.titleForRating()
  }
  
}
