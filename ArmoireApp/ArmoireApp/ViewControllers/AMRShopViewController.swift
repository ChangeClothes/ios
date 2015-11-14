//
//  AMRShopViewController.swift
//  ArmoireApp
//
//  Created by Morgan Wildermuth on 11/13/15.
//  Copyright © 2015 Armoire. All rights reserved.
//

import UIKit

class AMRShopViewController: UIViewController {

  @IBOutlet var collectionView: [UICollectionView]!

  // MARK: - Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    setupNavBar()
    // Do any additional setup after loading the view.
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }

  // MARK: - Initial Setup
  
  func setupNavBar(){
    self.title = "Stores"
    let leftNavBarButton = UIBarButtonItem(image: UIImage(named: "cancel"), style: .Plain, target: self, action: "exit")
    self.navigationItem.leftBarButtonItem = leftNavBarButton
  }
  // MARK: - On Tap Functions
  
  func exit(){
    self.dismissViewControllerAnimated(true, completion: nil)
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
