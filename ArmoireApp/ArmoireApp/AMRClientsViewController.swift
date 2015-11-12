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

  var sections = [String]()
  var clientSections = [String:[AMRUser]]()


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
    
    self.collectionView!.registerClass(UICollectionReusableView.self,
      forSupplementaryViewOfKind:UICollectionElementKindSectionHeader,
      withReuseIdentifier:"Header")

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


  func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
    if searchText != "" {
      filteredClients = clients.filter({
        let currentClient = $0
        return currentClient.fullName.lowercaseString.rangeOfString(searchText.lowercaseString) != nil
      })
      setUpSections(filteredClients!)
    } else {
      setUpSections(self.clients)
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
        self.setUpSections(self.clients)
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
    let client = clientSections[sections[indexPath.section]]![indexPath.row]
    let clientDetailVC = AMRClientsDetailViewController(layerClient: layerClient)
    clientDetailVC.stylist = self.stylist
    clientDetailVC.client = client
    let nav = UINavigationController(rootViewController: clientDetailVC)
    let formSheetController = MZFormSheetPresentationViewController(contentViewController: nav)
    let viewHeight = self.view.frame.height - 40
    let viewWidth = self.view.frame.width - 25
    formSheetController.presentationController?.contentViewSize = CGSizeMake(viewWidth, viewHeight)
    self.presentViewController(formSheetController, animated: true, completion: nil)

  }
  
  func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    if sections.count == 0 || section == 0 {
      return 0
    } else {
      return clientSections[sections[section - 1]]!.count
    }
  }

  func setUpSections(clients:[AMRUser]) {
    clientSections = [String:[AMRUser]]()
    for client in clients {
      let firstLetter = String(client.firstName[client.firstName.startIndex])
      if let _ = clientSections[firstLetter] {
        clientSections[firstLetter]!.append(client)
      } else {
        clientSections[firstLetter] = [client]
      }
    }
    sections = clientSections.keys.sort()
  }

  func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCellWithReuseIdentifier("ClientCell", forIndexPath: indexPath) as! clientCollectionViewCell
    let client = clientSections[sections[indexPath.section - 1]]![indexPath.row]
    cell.client = client
    AMRUserManager.sharedManager.queryForUserWithObjectID(client.objectId!) { (users: NSArray?, error: NSError?) -> Void in
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
    if section == 0 {
      return UIEdgeInsetsMake(0, 0, 0, 0)
    } else {
      return UIEdgeInsetsMake(-10, 0, 20, 0)
    }
  }
  
  func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
    if section == 0 {
      return CGSize(width: collectionView.frame.size.width, height: 40)
    } else {
      return CGSize(width: collectionView.frame.size.width, height: 30)
    }
  }

  func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {

    var v : UICollectionReusableView! = nil
    if kind == UICollectionElementKindSectionHeader {
      v = collectionView.dequeueReusableSupplementaryViewOfKind(UICollectionElementKindSectionHeader, withReuseIdentifier:"Header", forIndexPath:indexPath)
      if v.subviews.count == 0 {
        let lab = UILabel() // we will size it later
        v.addSubview(lab)
        lab.textAlignment = .Center
        lab.textColor = UIColor.AMRClientCollectionLabel()
        lab.layer.masksToBounds = true // has to be added for iOS 8 label
        lab.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activateConstraints([
          NSLayoutConstraint.constraintsWithVisualFormat("H:|-10-[lab(35)]",
            options:[], metrics:nil, views:["lab":lab]),
          NSLayoutConstraint.constraintsWithVisualFormat("V:[lab(30)]-5-|",
            options:[], metrics:nil, views:["lab":lab])
          ].flatten().map{$0})
      }
      let lab = v.subviews[0] as! UILabel
      if indexPath.section != 0 {
        lab.text = self.sections[indexPath.section - 1]
      } else {
        lab.text = ""
      }
    }
    return v
  }

  func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
    return sections.count + 1
  }
}
