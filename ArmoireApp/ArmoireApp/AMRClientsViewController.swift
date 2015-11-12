//
//  AMRClientsViewController.swift
//  ArmoireApp
//
//  Created by Morgan Wildermuth on 10/18/15.
//  Copyright © 2015 Armoire. All rights reserved.
//

import UIKit

class AMRClientsViewController: AMRViewController, UIGestureRecognizerDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UISearchBarDelegate {

  // MARK: - Outlets
  
  @IBOutlet weak var collectionView: UICollectionView!
  @IBOutlet weak var collectionViewConstraintTop: NSLayoutConstraint!
  var searchbar = UISearchBar()
  var layerClient: LYRClient!
  var filteredClients: [AMRUser]?
  var clients: [AMRUser] = []
  var searchActive = false

  // MARK: - Lifecycle

  convenience init(layerClient: LYRClient){
    self.init()
    self.layerClient = layerClient
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    searchbar.delegate = self
    searchbar.searchBarStyle = UISearchBarStyle.Minimal
    searchbar.frame = CGRectMake(0, 0, view.frame.width, 40)
    searchbar.frame.size.width = UIScreen.mainScreen().bounds.width
    self.collectionView.addSubview(searchbar)
    searchbar.layoutIfNeeded()
    loadClients()
    setUpClientCollectionView()
    self.title = "Clients"
    
    let leftNavBarButton = UIBarButtonItem(image: UIImage(named: "settings"), style: .Plain, target: self, action: "onSettingsTap")
    self.navigationItem.leftBarButtonItem = leftNavBarButton
    
    let rightNavBarButton = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "onAddClientType")
    self.navigationItem.rightBarButtonItem = rightNavBarButton

  // Do any additional setup after loading the view.
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  // MARK: - On Taps Functions

  func onSettingsTap(){
    showSettings()
  }
  
  func onAddClientType(){
    let addClientVC = AMRAddClientViewController()
    addClientVC.setVcData(self.stylist, client: nil)
    self.presentViewController(addClientVC, animated: true, completion: nil)
  }

  // MARK: - Table Set Up

  func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
    if searchText != "" {
      filteredClients = clients.filter({
        let currentClient = $0
        return currentClient.fullName.lowercaseString.rangeOfString(searchText.lowercaseString) != nil
      })
      searchActive = true
    } else {
      searchActive = false
      filteredClients = []
      searchBar.performSelector("resignFirstResponder", withObject: nil, afterDelay: 0)
    }
    self.collectionView.reloadData()
    searchBar.becomeFirstResponder()
  }

  func loadClients(){
    let userManager = AMRUserManager()
    userManager.queryForAllClientsOfStylist(self.stylist!) { (arrayOfUsers, error) -> Void in
      if let error = error {
        print(error.localizedDescription)
      } else {
        self.clients = (arrayOfUsers as? [AMRUser])!
        self.collectionView.reloadData()
      }
    }
  }

  func setUpClientCollectionView(){
    collectionView.dataSource = self
    collectionView.delegate = self
    let cellNib = UINib(nibName: "clientCollectionViewCell", bundle: nil)
    collectionView.registerNib(cellNib, forCellWithReuseIdentifier: "ClientCell")
    collectionView.backgroundColor = UIColor.whiteColor()
    self.view.addSubview(collectionView)
  }

  func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    searchbar.resignFirstResponder()
    collectionView.deselectItemAtIndexPath(indexPath, animated: true)
    let cell = collectionView.cellForItemAtIndexPath(indexPath) as? clientCollectionViewCell
    let clientDetailVC = AMRClientsDetailViewController(layerClient: layerClient)
    clientDetailVC.stylist = self.stylist
    clientDetailVC.client = cell!.client
    let nav = UINavigationController(rootViewController: clientDetailVC)
    let formSheetController = MZFormSheetPresentationViewController(contentViewController: nav)
    let viewHeight = self.view.frame.height - 40
    let viewWidth = self.view.frame.width - 25
    formSheetController.presentationController?.contentViewSize = CGSizeMake(viewWidth, viewHeight)
    self.presentViewController(formSheetController, animated: true, completion: nil)

  }
  
  func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    if searchActive {
      return (filteredClients?.count)!
    } else {
      return clients.count
    }
  }

  func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCellWithReuseIdentifier("ClientCell", forIndexPath: indexPath) as! clientCollectionViewCell
    var client: AMRUser?
    if searchActive {
      client = filteredClients![indexPath.row]
    } else {
      client = clients[indexPath.row]
    }
    cell.client = client
    AMRUserManager.sharedManager.queryForUserWithObjectID(client!.objectId!) { (users: NSArray?, error: NSError?) -> Void in
      if let error = error {
        print(error.localizedDescription)
      } else {
        let user = users!.firstObject! as! AMRUser
        if let profileImage = user.profilePhoto {
          cell.imageView.setAMRImage(profileImage, withPlaceholder: "profile-image-placeholder", withCompletion: { (success) -> Void in
            cell.activityIndicatorView.stopAnimating()
          })
        } else {
          cell.imageView.setAMRImage(nil, withPlaceholder: "profile-image-placeholder")
          cell.activityIndicatorView.stopAnimating()
        }
      }
    }

    cell.imageView.backgroundColor = UIColor.grayColor()
    return cell
  }
  
  func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
    return CGSizeMake(180, 150)
  }
  
  func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
    return UIEdgeInsetsMake(0, 0, 0, 0)
  }
  
  func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
    return CGSize(width: collectionView.frame.size.width, height: 40)
  }
}
