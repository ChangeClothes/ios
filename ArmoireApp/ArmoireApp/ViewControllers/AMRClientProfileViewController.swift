//
//  AMRClientProfileViewController.swift
//  ArmoireApp
//
//  Created by Morgan Wildermuth on 10/26/15.
//  Copyright © 2015 Armoire. All rights reserved.
//

import UIKit

class AMRClientProfileViewController: AMRViewController, UIAlertViewDelegate{
  
  // MARK: - IBOutlets
  @IBOutlet weak var containerView: UIView!
  @IBOutlet weak var segmentedControl: UISegmentedControl!
  @IBOutlet weak var pageSelectionIndicatorXConstraint: NSLayoutConstraint!
  @IBOutlet weak var pageSelectionIndicatorView: UIView!
  
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
      movePageSelectionIndicatorToIndex(0)
    case 1:
      let initialViewControllerArray = [vcArray[1]]
      pageController.setViewControllers(initialViewControllerArray, direction: .Forward, animated: true, completion: nil)
      movePageSelectionIndicatorToIndex(1)
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
    setupPageController()
    setupSegmentedControl()
    setupPageSelectionIndicatorView()
    setUpNavBar()
    
  }
  
  
  
  // MARK: - Initial Setup
  private func setVcDataForTabs(){
    for (_, value) in vcArray.enumerate() {
      let vc = (value as! UINavigationController).viewControllers.first as? AMRViewController
      vc?.setVcData(self.stylist, client: self.client)
    }
  }
  
  private func setVcArray(){
    let photoVC = AMRPhotosViewController()
    let measurementsVC = AMRMeasurementsViewController()
    vcArray = [UINavigationController(rootViewController: photoVC), UINavigationController(rootViewController: measurementsVC)]
  }
  
  func dismissKeyboard(sender: UITapGestureRecognizer) {
    self.view.endEditing(true)
  }
  
  private func setupPageController() {
    pageController = UIPageViewController(transitionStyle: .Scroll, navigationOrientation: .Horizontal, options: nil)
    pageController.dataSource = self
    pageController.delegate = self
    pageController.view.frame = containerView.bounds
    
    let initialViewControllerArray = [vcArray[0]]
    pageController.setViewControllers(initialViewControllerArray, direction: .Forward, animated: true, completion: nil)
    addChildViewController(pageController)
    containerView.addSubview(pageController.view)
    pageController.didMoveToParentViewController(self)
    
    for view in self.pageController.view.subviews {
      if view.isKindOfClass(UIScrollView.self) == true {
        (view as! UIScrollView).scrollEnabled = false
      }
    }
  }
  
  internal func setUpNavBar(){
    if (stylist != nil && client != nil){
      let leftNavBarButton = UIBarButtonItem(image: UIImage(named: "cancel"), style: .Plain, target: self, action: "exitModal")
      self.navigationItem.leftBarButtonItem = leftNavBarButton
    } else {
      let leftNavBarButton = UIBarButtonItem(image: UIImage(named: "settings"), style: .Plain, target: self, action: "onSettingsTap")
      self.navigationItem.leftBarButtonItem = leftNavBarButton
    }
    if (client != nil){
      self.title = (client?.firstName)! + " " + (client?.lastName)!
    }
  }
  
  private func setupSegmentedControl(){
    segmentedControl.setBackgroundImage(imageWithColor(UIColor.clearColor()), forState: .Normal, barMetrics: .Default)
    segmentedControl.setBackgroundImage(imageWithColor(UIColor.clearColor()), forState: .Selected, barMetrics: .Default)
    segmentedControl.setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.AMRSecondaryBackgroundColor()], forState: .Normal)
    segmentedControl.setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.AMRSelectedTabBarButtonTintColor()], forState: .Selected)
    segmentedControl.setDividerImage(imageWithColor(UIColor.clearColor()), forLeftSegmentState: .Normal, rightSegmentState: .Normal, barMetrics: .Default)
  }
  
  private func setupPageSelectionIndicatorView() {
    pageSelectionIndicatorView.backgroundColor = UIColor.AMRSelectedTabBarButtonTintColor()
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
  
  private func movePageSelectionIndicatorToIndex(index: Int) {
    UIView.animateWithDuration(0.4, animations: { () -> Void in
      self.pageSelectionIndicatorView.setNeedsLayout()
      if index == 0 {
        self.pageSelectionIndicatorXConstraint.constant = 0
      } else if index == 1 {
        self.pageSelectionIndicatorXConstraint.constant = self.segmentedControl.frame.width/2
      }
      
      self.pageSelectionIndicatorView.layoutIfNeeded()
      
      }, completion: nil)
  }
  
  // MARK: - Bar Button Actions
  func onSettingsTap(){
    showSettings()
  }
  
  func exitModal(){
    self.dismissViewControllerAnimated(true, completion: nil)
  }
  
}


//MARK: UIPageViewController Datasource and Delegate
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
      movePageSelectionIndicatorToIndex(0)
    } else {
      segmentedControl.selectedSegmentIndex = 1
      movePageSelectionIndicatorToIndex(1)
    }
  }
  
  func pageViewController(pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
    if !completed {
      if segmentedControl.selectedSegmentIndex == 0 {
        segmentedControl.selectedSegmentIndex = 1
        movePageSelectionIndicatorToIndex(1)
      } else {
        segmentedControl.selectedSegmentIndex = 0
        movePageSelectionIndicatorToIndex(0)
      }
    }
    if previousViewControllers[0].isEqual(vcArray[0]) {
      if ((vcArray[1] as! UINavigationController).viewControllers.first as! AMRMeasurementsViewController).view.gestureRecognizers == nil {
        let dismissKeyboardGR = UITapGestureRecognizer(target: self, action: "dismissKeyboard:")
        (vcArray[1] as! UINavigationController).viewControllers.first?.view.addGestureRecognizer(dismissKeyboardGR)
      }
    }
    
  }
  
}
