//
//  AMRPhotosViewController.swift
//  ArmoireApp
//
//  Created by Mathew Kellogg on 10/27/15.
//  Copyright © 2015 Armoire. All rights reserved.
//

import UIKit

let imageCellReuseIdentifier = "cell"

class AMRPhotosViewController: UIViewController, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, AMRViewControllerProtocol{

  
  @IBOutlet weak var collectionView: UICollectionView!
  var stylist: AMRUser?
  var client: AMRUser?
  var photos: [AMRImage] = []
  
  func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
      return photos.count
  }
  
  func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    
    let cell = collectionView.dequeueReusableCellWithReuseIdentifier(imageCellReuseIdentifier, forIndexPath: indexPath) as UICollectionViewCell
    let image = photos[indexPath.row]
    let imageView = UIImageView()
    imageView.setAMRImage(image)
    cell.backgroundView = imageView
    return cell
  }
  
  
  override func viewDidLoad() {
    AMRImage.imagesForUser(stylist, client: client) { (objects, error) -> Void in
      self.photos = objects! as [AMRImage]
      self.collectionView.reloadData()
    }
    //super.viewDidLoad()
    //let cellNib = UINib(nibName: "AMRImageCell", bundle: nil)
    //collectionView.registerNib(cellNib, forCellWithReuseIdentifier: imageCellReuseIdentifier)
    //self.navigationController?.setNavigationBarHidden(true, animated: false)
    
    // Do any additional setup after loading the view, typically from a nib.
    let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
    layout.sectionInset = UIEdgeInsets(top: 20, left: 10, bottom: 10, right: 10)
    layout.itemSize = CGSize(width: 90, height: 120)
    
    collectionView.dataSource = self
    collectionView.delegate = self
    collectionView.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: "Cell")
    collectionView.backgroundColor = UIColor.whiteColor()
    self.view.addSubview(collectionView)
    
    // Do any additional setup after loading the view.
  }
  
  internal func setVcData(stylist: AMRUser?, client: AMRUser?) {
    self.stylist = stylist
    self.client = client
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
}
