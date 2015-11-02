//
//  AMRClientProfileViewController.swift
//  ArmoireApp
//
//  Created by Morgan Wildermuth on 10/26/15.
//  Copyright © 2015 Armoire. All rights reserved.
//

import UIKit

class AMRClientProfileViewController: AMRViewController, UIAlertViewDelegate, AMRViewControllerProtocol{
  
  // MARK: - IBOutlets
  @IBOutlet weak var containerView: UIView!
  @IBOutlet weak var segmentedControl: UISegmentedControl!
  
  // MARK: - Class Properties
  var selectedViewController: UIViewController?
  var vcArray: [UIViewController]!
  var pageController: UIPageViewController!
  
  // MARK: - IBActions
  @IBAction func segmentedControlDidChange(sender: UISegmentedControl) {
    switch sender.selectedSegmentIndex {
    case 0:
      let initialViewControllerArray = [vcArray[0]]
      pageController.setViewControllers(initialViewControllerArray, direction: .Reverse, animated: true, completion: nil)
    case 1:
      let initialViewControllerArray = [vcArray[1]]
      pageController.setViewControllers(initialViewControllerArray, direction: .Forward, animated: true, completion: nil)
    default:
      break
    }
  }
  
  // MARK: - Lifecycle
  override func viewDidLoad() {
    self.navigationController?.navigationBar.translucent = false
    super.viewDidLoad()
    
    setVcArray()
    setVcDataForTabs()
    
    pageController = UIPageViewController(transitionStyle: .Scroll, navigationOrientation: .Horizontal, options: nil)
    pageController.dataSource = self
    pageController.delegate = self
    pageController.view.frame = containerView.bounds
    
    let initialViewControllerArray = [vcArray[0]]
    pageController.setViewControllers(initialViewControllerArray, direction: .Forward, animated: true, completion: nil)
    addChildViewController(pageController)
    containerView.addSubview(pageController.view)
    pageController.didMoveToParentViewController(self)
    
  }
  
  // MARK: - Initial Setup
  func setVcData(stylist: AMRUser?, client: AMRUser?) {
    self.stylist = stylist
    self.client = client
    if (client != nil){
      self.title = (client?.firstName)! + " " + (client?.lastName)!
    }
    setUpNavBar()
  }
  
  private func setVcDataForTabs(){
    for (index, value) in vcArray.enumerate() {
      let vc = (value as! UINavigationController).viewControllers.first as? AMRViewControllerProtocol
      vc?.setVcData(self.stylist, client: self.client)
    }
  }
  
  private func setVcArray(){
    let photoVC = AMRPhotosViewController()
    let measurementsVC = AMRMeasurementsViewController()
    
    //    measurement.View.addGestureRecognizer(dismissKeyboardGR)
    vcArray = [UINavigationController(rootViewController: photoVC), UINavigationController(rootViewController: measurementsVC)]
  }
  
  func dismissKeyboard(sender: UITapGestureRecognizer) {
    self.view.endEditing(true)
  }
  
  internal func setUpNavBar(){
    if (stylist != nil && client != nil){
      let leftNavBarButton = UIBarButtonItem(image: UIImage(named: "cancel"), style: .Plain, target: self, action: "exitModal")
      self.navigationItem.leftBarButtonItem = leftNavBarButton
    } else {
      let leftNavBarButton = UIBarButtonItem(image: UIImage(named: "settings"), style: .Plain, target: self, action: "onSettingsTap")
      self.navigationItem.leftBarButtonItem = leftNavBarButton
    }
  }
  
  // MARK: - Bar Button Actions
  func onSettingsTap(){
    showSettings()
  }
  
  func exitModal(){
    self.dismissViewControllerAnimated(true, completion: nil)
  }
  
}

extension AMRClientProfileViewController: UIPageViewControllerDataSource, UIPageViewControllerDelegate {
  func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
    if viewController.isEqual(vcArray[0]) {
      return nil
    }
    
    return vcArray[0]
  }
  
  func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
    if viewController.isEqual(vcArray[1]) {
      return nil
    }
    
    return vcArray[1]
  }
  
  func pageViewController(pageViewController: UIPageViewController, willTransitionToViewControllers pendingViewControllers: [UIViewController]) {
    if pendingViewControllers[0].isEqual(vcArray[0]){
      segmentedControl.selectedSegmentIndex = 0
    } else {
      segmentedControl.selectedSegmentIndex = 1
    }
  }
  
  func pageViewController(pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
    if previousViewControllers[0].isEqual(vcArray[0]) {
      if ((vcArray[1] as! UINavigationController).viewControllers.first as! AMRMeasurementsViewController).view.gestureRecognizers == nil {
        let dismissKeyboardGR = UITapGestureRecognizer(target: self, action: "dismissKeyboard:")
        (vcArray[1] as! UINavigationController).viewControllers.first?.view.addGestureRecognizer(dismissKeyboardGR)
      }
    }
    
  }
  
}

