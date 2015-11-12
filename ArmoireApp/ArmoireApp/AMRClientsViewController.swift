//
//  AMRClientsViewController.swift
//  ArmoireApp
//
//  Created by Morgan Wildermuth on 10/18/15.
//  Copyright © 2015 Armoire. All rights reserved.
//

import UIKit

//class AMRClientsViewController: AMRViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UIGestureRecognizerDelegate {

class AMRClientsViewController: AMRViewController, UIGestureRecognizerDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UISearchBarDelegate {

  // MARK: - Outlets
  
  @IBOutlet weak var collectionView: UICollectionView!
//  @IBOutlet weak var clientTable: UITableView!
//
//  // MARK: - Constants
//
//  let cellConstant = "clientTableViewCellReuseIdentifier"
//
//  // MARK: - Properties
//
  @IBOutlet weak var collectionViewConstraintTop: NSLayoutConstraint!
  var tap: UITapGestureRecognizer!
  var searchbar = UISearchBar()
  var layerClient: LYRClient!
//  var sections = [String]()
//  var clientSections = [String:[AMRUser]]()
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
    searchbar.setShowsCancelButton(true, animated: false)
    searchbar.frame = CGRectMake(0, 0, view.frame.width, 40)
    searchbar.frame.size.width = UIScreen.mainScreen().bounds.width
    self.collectionView.addSubview(searchbar)
    searchbar.layoutIfNeeded()
    loadClients()
    setUpClientCollectionView()
    self.title = "Clients"
    
    self.tap = UITapGestureRecognizer(target: self, action: "viewTapped:")
    self.tap.delegate = self
    self.view.addGestureRecognizer(self.tap)
    
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

//  func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
//    print("otuched")
////    searchbar.resignFirstResponder()
//    return false
//  }

  func onSettingsTap(){
//    showSettings()
  }
  
//
//  func onAddClientType(){
//    let addClientVC = AMRAddClientViewController()
//    addClientVC.setVcData(self.stylist, client: nil)
//    self.presentViewController(addClientVC, animated: true, completion: nil)
//  }

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
//        self.setUpSections(self.clients!)
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

//  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
//    let cell = clientTable.dequeueReusableCellWithIdentifier(cellConstant, forIndexPath: indexPath) as! AMRClientTableViewCell
//    cell.client = clientSections[sections[indexPath.section]]![indexPath.row]
//    cell.textLabel!.text = cell.client?.fullName
//    return cell
//  }
//
//  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
//    tableView.deselectRowAtIndexPath(indexPath, animated: true)
//    let cell = clientTable.cellForRowAtIndexPath(indexPath) as! AMRClientTableViewCell
//    let clientDetailVC = AMRClientsDetailViewController(layerClient: layerClient)
//    clientDetailVC.stylist = self.stylist
//    clientDetailVC.client = cell.client
//    let nav = UINavigationController(rootViewController: clientDetailVC)
//    let formSheetController = MZFormSheetPresentationViewController(contentViewController: nav)
//    let viewHeight = self.view.frame.height - 40
//    let viewWidth = self.view.frame.width - 25
//    formSheetController.presentationController?.contentViewSize = CGSizeMake(viewWidth, viewHeight)
//    self.presentViewController(formSheetController, animated: true, completion: nil)
//  }
//

  func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    collectionView.deselectItemAtIndexPath(indexPath, animated: true)

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
