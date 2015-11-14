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
  var inventoryCategoryHistory = InventoryCategoryStack()
  var currentItems: [AMRInventoryItem]?
  var selectedPhotos = [UIImage]()
  var client: AMRUser?

  @IBOutlet weak var collectionView: UICollectionView!

  // MARK: - Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    loadData()
    setupClientCollectionView()
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
    setUpRightNavBarItem()
  }

  func setUpRightNavBarItem(){
    var rightNavBarButton: UIBarButtonItem?

    if currentItems != nil && selectedPhotos.count > 0 {
      rightNavBarButton = UIBarButtonItem(image: UIImage(named: "check"), style: .Plain, target: self, action: "approveAdditions")
    } else {
      if inventoryCategoryHistory.count > 1 {
        rightNavBarButton = UIBarButtonItem(image: UIImage(named: "undo"), style: .Plain, target: self, action: "revertToPreviousCategory")
      } else {
        rightNavBarButton = nil
      }
    }

    self.navigationItem.rightBarButtonItem = rightNavBarButton
  }

  func loadData(){
    inventory = AMRInventory.get_inventory()
    inventoryCategoryHistory.push((inventory?.categories)!)
  }

  // MARK: - Collection View

  func setupClientCollectionView(){
    collectionView.dataSource = self
    collectionView.delegate = self
    let cellNib = UINib(nibName: "AMRCategoryCollectionViewCell", bundle: nil)
    collectionView.registerNib(cellNib, forCellWithReuseIdentifier: "CategoryCell")
    let itemCellNib = UINib(nibName: "AMRInventoryItemCollectionViewCell", bundle: nil)
    collectionView.registerNib(itemCellNib, forCellWithReuseIdentifier: "ItemCell")
    collectionView.backgroundColor = UIColor.whiteColor()
    self.view.addSubview(collectionView)
  }

  func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    if let items = currentItems {
      selectedItemCell(indexPath, items: items)
    } else {
      selectedCategoryCell(indexPath)
    }
    setUpRightNavBarItem()
  }

  func selectedCategoryCell(indexPath: NSIndexPath){
    let category = inventoryCategoryHistory.topItem![indexPath.row]
    if let items = category.items {
      currentItems = items
    } else if let subcategories = category.subcategories{
      collectionView.deselectItemAtIndexPath(indexPath, animated: true)
      inventoryCategoryHistory.push(subcategories)
    } else {
      print("issue with didSelectItem: neither items or subcategories present")
    }
    collectionView.reloadData()
  }

  func selectedItemCell(indexPath: NSIndexPath, items: [AMRInventoryItem]){
    let item = items[indexPath.row]
    var selectedCell = collectionView.cellForItemAtIndexPath(indexPath) as! AMRInventoryItemCollectionViewCell
    if selectedCell.layer.borderWidth == 2.0 {
      selectedCell.layer.borderWidth = 0.0
      deselectItem(selectedCell.imageView.image!)
    } else {
      selectedCell.layer.borderWidth = 2.0
      selectedCell.layer.borderColor = UIColor.grayColor().CGColor
      selectItem((selectedCell.imageView?.image)!)
    }
  }

  func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    if let items = currentItems {
      return items.count
    } else {
      return inventoryCategoryHistory.topItem!.count
    }
  }

  func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {

    let itemCell: AMRInventoryItemCollectionViewCell?
    let categoryCell: AMRCategoryCollectionViewCell?

    if let items = currentItems {
      itemCell = collectionView.dequeueReusableCellWithReuseIdentifier("ItemCell", forIndexPath: indexPath) as! AMRInventoryItemCollectionViewCell
      let item = items[indexPath.row]
      itemCell!.item = item
      return itemCell!
    } else {
      categoryCell = collectionView.dequeueReusableCellWithReuseIdentifier("CategoryCell", forIndexPath: indexPath) as! AMRCategoryCollectionViewCell
      let category = inventoryCategoryHistory.topItem![indexPath.row]
      categoryCell!.category = category
      return categoryCell!
    }
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
  
  func approveAdditions(){
    for item in selectedPhotos {
      createAMRImage(item)
    }
    self.dismissViewControllerAnimated(true, completion: nil)
  }

  func revertToPreviousCategory(){
    if let items = currentItems {
      currentItems = nil
      selectedPhotos = [UIImage]()
    } else {
      inventoryCategoryHistory.pop()
    }
    collectionView.reloadData()
    setUpRightNavBarItem()
  }

  // MARK: - Item Engagemenet

  func selectItem(item: UIImage){
    selectedPhotos.append(item)
    setUpRightNavBarItem()
  }

  func deselectItem(item: UIImage){
    var deleteAtIndex: Int?
    for (index, element) in selectedPhotos.enumerate() {
      if item === element {
        deleteAtIndex = index
      }
    }
    selectedPhotos.removeAtIndex(deleteAtIndex!)
    setUpRightNavBarItem()
  }

  // MARK: - Create AMRImage

  private func createAMRImage(item: UIImage){
    let image = PFObject(className: "Image")
    if let client = self.client {
      image.setObject(client, forKey: "client")
    }
    image.setObject(AMRUser.currentUser()!, forKey: "stylist")
    let imageData = UIImagePNGRepresentation(item)
    let imageFile = PFFile(data: imageData!)
    image.setObject(imageFile!, forKey: "file")
    image.saveInBackgroundWithBlock { (success: Bool, error: NSError?) -> Void in
      if let error = error {
        print(error.localizedDescription)
      } else {
        print("Saved")
      }
    }
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

struct InventoryCategoryStack {
  var items = [[AMRInventoryCategory]]()

  mutating func push(item: [AMRInventoryCategory]){
    items.append(item)
  }

  mutating func pop() -> [AMRInventoryCategory] {
    return items.removeLast()
  }

  var topItem: [AMRInventoryCategory]? {
    return items.isEmpty ? nil : items[items.count - 1]
  }

  var count: Int {
    return items.count
  }

}