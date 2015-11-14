//
//  AMRShopViewController.swift
//  ArmoireApp
//
//  Created by Morgan Wildermuth on 11/13/15.
//  Copyright © 2015 Armoire. All rights reserved.
//

import UIKit

class AMRShopViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{

  var inventory: AMRInventory?
  var inventoryCategoryHistory: [[AMRInventoryCategory]] = []
  var currentItems: [AMRInventoryItem]?

  @IBOutlet weak var collectionView: UICollectionView!

  // MARK: - Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    setupNavBar()
    loadData()
    setupClientCollectionView()
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

  func loadData(){
    inventory = AMRInventory.get_inventory()
    inventoryCategoryHistory.append((inventory?.categories)!)
  }

  // MARK: - Collection View

  func setupClientCollectionView(){
    collectionView.dataSource = self
    collectionView.delegate = self
    let cellNib = UINib(nibName: "AMRCategoryCollectionViewCell", bundle: nil)
    collectionView.registerNib(cellNib, forCellWithReuseIdentifier: "CategoryCell")
    collectionView.backgroundColor = UIColor.whiteColor()
    self.view.addSubview(collectionView)
  }

  func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    collectionView.deselectItemAtIndexPath(indexPath, animated: true)
    let category = inventoryCategoryHistory.last![indexPath.row]
    if let items = category.items {
      currentItems = items
    } else if let subcategories = category.subcategories{
      inventoryCategoryHistory.append(subcategories)
    } else {
      print("issue with didSelectItem: neither items or subcategories present")
      print(category)
    }
    collectionView.reloadData()
  }

  func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    if let items = currentItems {
      return items.count
    } else {
      return inventoryCategoryHistory.last!.count
    }
  }

  func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
//    if let items = currentItems {
//      print("selected item: need to create cells for items")
//      let item = items[indexPath.row]
//    } else {
      let cell = collectionView.dequeueReusableCellWithReuseIdentifier("CategoryCell", forIndexPath: indexPath) as! AMRCategoryCollectionViewCell
      let category = inventoryCategoryHistory.last![indexPath.row]
      cell.category = category
//    }
    return cell
  }

  func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
    return CGSizeMake(115, 150)
  }

  func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
    return UIEdgeInsetsMake(-10, 0, 20, 0)
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
