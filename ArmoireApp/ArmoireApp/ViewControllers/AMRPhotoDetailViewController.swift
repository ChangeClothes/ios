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
  
  weak var delegate: AMRPhotoDetailViewControllerDelegate?
  
  var photo: AMRImage?

  override func viewDidLoad() {
    super.viewDidLoad()

    containerViewController.setAMRImage(photo!)
    let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismiss:")
    containerViewController.addGestureRecognizer(tapGestureRecognizer)
  }
  
  func dismiss(sender: UITapGestureRecognizer){
    self.delegate?.AMRPhotoDetailVIewController(self, didDismiss: true)
  }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
