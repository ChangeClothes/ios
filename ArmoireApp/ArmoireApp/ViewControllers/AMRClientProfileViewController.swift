//
//  AMRClientProfileViewController.swift
//  ArmoireApp
//
//  Created by Morgan Wildermuth on 10/26/15.
//  Copyright © 2015 Armoire. All rights reserved.
//

import UIKit

class AMRClientProfileViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIAlertViewDelegate, AMRViewControllerProtocol{

  @IBOutlet weak var profieImage: UIImageView!
  @IBOutlet weak var containerView: UIView!
  @IBOutlet weak var measurementImageView: UIImageView!
  @IBOutlet weak var cameraImageView: UIImageView!
  
  /*******************************
   *** AMRViewController LOGIC ***
   ******************************/
  var stylist: AMRUser?
  var client: AMRUser?
  var selectedViewController: UIViewController?
  var vcArray: [UINavigationController]!

  //actions
  @IBAction func cameraTap(sender: UITapGestureRecognizer) {
    selectViewController(vcArray[1])
  }
  
  @IBAction func measurementTap(sender: UITapGestureRecognizer) {
    selectViewController(vcArray[0])
  }
  
  @IBAction func profileTap(sender: UITapGestureRecognizer) {
  }
  
  override func viewDidLoad() {
    self.navigationController?.navigationBar.translucent = false
    super.viewDidLoad()
    setVcArray()
    setVcDataForTabs()
    selectViewController(vcArray[0])
    loadProfile()
  }
  func setVcData(stylist: AMRUser?, client: AMRUser?) {
    self.stylist = stylist
    self.client = client
    if (client != nil){
      self.title = (client?.firstName)! + " " + (client?.lastName)!
    }
    loadProfile()
    setUpNavBar()

  }

  func onSettingsTap(){
    let settingsVC = AMRSettingsViewController()
    self.presentViewController(settingsVC, animated: true, completion: nil)
  }

  internal func setUpNavBar(){
    if (stylist != nil && client != nil){
      let exitModalButton: UIButton = UIButton()
      exitModalButton.setImage(UIImage(named: "undo"), forState: .Normal)
      exitModalButton.frame = CGRectMake(0, 0, 30, 30)
      exitModalButton.addTarget(self, action: Selector("exitModal"), forControlEvents: .TouchUpInside)

      let leftNavBarButton = UIBarButtonItem(customView: exitModalButton)
      self.navigationItem.leftBarButtonItem = leftNavBarButton
    } else {
      let settings: UIButton = UIButton()
      settings.setImage(UIImage(named: "settings"), forState: .Normal)
      settings.frame = CGRectMake(0, 0, 30, 30)
      settings.addTarget(self, action: Selector("onSettingsTap"), forControlEvents: .TouchUpInside)

      let leftNavBarButton = UIBarButtonItem(customView: settings)
      self.navigationItem.leftBarButtonItem = leftNavBarButton
    }
  }

  func exitModal(){
    self.dismissViewControllerAnimated(true, completion: nil)
  }
  
  private func setVcDataForTabs(){
    for (index, value) in vcArray.enumerate() {
      let vc = value.viewControllers.first as? AMRViewControllerProtocol
      vc?.setVcData(self.stylist, client: self.client)
    }
  }
  
  private func setVcArray(){
    let photoVC = UINavigationController(rootViewController: AMRPhotosViewController())
    let measurementsVC = UINavigationController(rootViewController: AMRMeasurementsViewController())
    vcArray = [measurementsVC, photoVC]
  }
  
  func selectViewController(viewController: UIViewController){
    if let oldViewController = selectedViewController{
      oldViewController.willMoveToParentViewController(nil)
      oldViewController.view.removeFromSuperview()
      oldViewController.removeFromParentViewController()
    }
    
    self.addChildViewController(viewController)
    viewController.view.frame = self.containerView.bounds
    viewController.view.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
    self.containerView.addSubview(viewController.view)
    viewController.didMoveToParentViewController(self)
    selectedViewController = viewController
  }
  
  /******************
  *** PHOTO LOGIC ***
  ******************/
  var photoVC: UIImagePickerController? = nil
  var pickerVC:UIImagePickerController?=UIImagePickerController()
  
  func openCamera() {
    photoVC = UIImagePickerController()
    photoVC!.delegate = self
    photoVC!.allowsEditing = true
    photoVC!.sourceType = UIImagePickerControllerSourceType.Camera
    self.presentViewController(photoVC!, animated: true, completion: nil)
  }
  
  func openGallery() {
    photoVC = UIImagePickerController()
    photoVC!.delegate = self
    photoVC!.allowsEditing = true
    photoVC!.sourceType = UIImagePickerControllerSourceType.SavedPhotosAlbum
    self.presentViewController(photoVC!, animated: true, completion: nil)
  }
  
  func selectPhoto(){
    
    let alert:UIAlertController=UIAlertController(title: "Choose Image", message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
    pickerVC?.delegate = self
    
    let cameraAction = UIAlertAction(title: "Take Photo", style: UIAlertActionStyle.Default)
      {
        UIAlertAction in
        self.openCamera()
        
    }
    let galleryAction = UIAlertAction(title: "Select Photo", style: UIAlertActionStyle.Default){
      UIAlertAction in
      self.openGallery()
    }
    let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel) {
      UIAlertAction in
    }
    // Add the actions
    if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera){
      alert.addAction(cameraAction)
      
    }
    if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.SavedPhotosAlbum) {
      alert.addAction(galleryAction)
    }
    alert.addAction(cancelAction)

    self.presentViewController(alert, animated: true, completion: nil)

  }
  
  func imagePickerController(picker: UIImagePickerController,
    didFinishPickingMediaWithInfo info: [String : AnyObject]) {
      let originalImage = info[UIImagePickerControllerOriginalImage] as? UIImage
      let editedImage = info[UIImagePickerControllerEditedImage] as? UIImage
      
      var image: UIImage? = nil
      if (editedImage != nil) {
        image = editedImage
      } else if originalImage != nil {
        image = originalImage
      } else {
        // prolly won't happen. what should we do here?
      }
      
      self.profieImage.image = image
      
      let storedImage = AMRImage()
      storedImage.stylist = self.stylist
      storedImage.client = self.client
      storedImage.setImage(image!)
      
      //dismiss view controller
      self.photoVC?.dismissViewControllerAnimated(true, completion: { () -> Void in
        self.photoVC = nil
      })
      
  }
  //END PHOTO LOGIC
  
  
  
  func loadProfile(){
    
  }
  
  @IBAction func onTap(sender: AnyObject) {
    selectPhoto()
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
}
