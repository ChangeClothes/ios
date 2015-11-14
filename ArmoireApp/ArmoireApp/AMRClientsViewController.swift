//
//  AMRClientsViewController.swift
//  ArmoireApp
//
//  Created by Morgan Wildermuth on 10/18/15.
//  Copyright © 2015 Armoire. All rights reserved.
//

import UIKit

class AMRClientsViewController: AMRViewController, UIGestureRecognizerDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UISearchBarDelegate {

  let kTodayTableReuseIdentifier = "com.armoire.TodayTableReuseIdentifier"
  
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
    self.title = "Clients"
    setUpSearchBar()
    loadClients()
    setUpClientCollectionView()

    let leftNavBarButton = UIBarButtonItem(image: UIImage(named: "settings"), style: .Plain, target: self, action: "onSettingsTap")
    self.navigationItem.leftBarButtonItem = leftNavBarButton
    
    let rightNavBarButton = UIBarButtonItem(image: UIImage(named: "add-client"), style: .Plain, target: self, action: "onAddClientType")
    self.navigationItem.rightBarButtonItem = rightNavBarButton

    NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateTableView", name: kDismissedModalNotification, object: nil)
    updateTableView()
  // Do any additional setup after loading the view.
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  func updateTableView() {
    AMRBadgeManager.sharedInstance.getClientBadgesForStylist(AMRUser.currentUser()!) { (clientBadges) -> Void in
      self.collectionView.reloadData()
    }
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

  // MARK: search bar

  private func setUpSearchBar(){
    searchbar.delegate = self
    searchbar.searchBarStyle = UISearchBarStyle.Minimal
    searchbar.frame = CGRectMake(0, 0, view.frame.width, 40)
    searchbar.frame.size.width = UIScreen.mainScreen().bounds.width
    self.collectionView.addSubview(searchbar)
    searchbar.layoutIfNeeded()
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

  // MARK: clients

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

  // MARK: Collection View

  func setUpClientCollectionView(){
    collectionView.dataSource = self
    collectionView.delegate = self
    let cellNib = UINib(nibName: "clientCollectionViewCell", bundle: nil)
    collectionView.registerNib(cellNib, forCellWithReuseIdentifier: "ClientCell")
    collectionView.backgroundColor = UIColor.whiteColor()
    self.view.addSubview(collectionView)
    self.collectionView!.registerClass(UICollectionReusableView.self,
      forSupplementaryViewOfKind:UICollectionElementKindSectionHeader,
      withReuseIdentifier:"Header")
    
    let todayCellNib = UINib(nibName: "AMRTodayTableCollectionViewCell", bundle: nil)
    collectionView.registerNib(todayCellNib, forCellWithReuseIdentifier: kTodayTableReuseIdentifier)
  }

  func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    searchbar.resignFirstResponder()
    collectionView.deselectItemAtIndexPath(indexPath, animated: true)
    let client = clientSections[sections[indexPath.section - 1]]![indexPath.row]
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
    if sections.count == 0 {
      return 0
    } else if section == 0 {
      return 1
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
    if indexPath.section == 0 {
      let cell = collectionView.dequeueReusableCellWithReuseIdentifier(kTodayTableReuseIdentifier, forIndexPath: indexPath) as! AMRTodayTableCollectionViewCell
      cell.updateData()
  
      cell.delegate = self
      return cell
    } else {
      let cell = collectionView.dequeueReusableCellWithReuseIdentifier("ClientCell", forIndexPath: indexPath) as! clientCollectionViewCell
      let client = clientSections[sections[indexPath.section - 1]]![indexPath.row]
      print(client)
      cell.client = client
      cell.imageView.backgroundColor = UIColor.grayColor()
      return cell
    }
    
  }
  
  func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
    if indexPath.section == 0 {
      return CGSizeMake(collectionView.bounds.width, CGFloat(AMRBadgeManager.sharedInstance.clientBadges.count)*90)
    } else {
      return CGSizeMake(115, 200)
    }
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
  
  deinit {
    NSNotificationCenter.defaultCenter().removeObserver(self)
  }
}

extension AMRClientsViewController: AMRTodayTableCollectionViewCellDelegate{
  func todayTableCollectionViewCell(cell: AMRTodayTableCollectionViewCell, didSelectClient client: AMRUser) {
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
}
