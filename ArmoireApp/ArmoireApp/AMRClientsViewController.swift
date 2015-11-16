//
//  AMRClientsViewController.swift
//  ArmoireApp
//
//  Created by Morgan Wildermuth on 10/18/15.
//  Copyright © 2015 Armoire. All rights reserved.
//

import UIKit

let kNewMessageReceivedNotification = "com.armoire.NewMessageReceivedNotification"

class AMRClientsViewController: AMRViewController, UIGestureRecognizerDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UISearchBarDelegate {

  let kTodayTableReuseIdentifier = "com.armoire.TodayTableReuseIdentifier"
  let kSectionHeaderReuseIdentifier = "com.armoire.SectionHeaderReuseIdentifier"
  // MARK: - Outlets
  
  @IBOutlet weak var collectionView: UICollectionView!
  @IBOutlet weak var collectionViewConstraintTop: NSLayoutConstraint!
  var searchbar = UISearchBar()
  var layerClient: LYRClient!
  var filteredClients: [AMRUser]?
  var clients: [AMRUser] = []
  var searchActive = true


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
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateTableView", name: kNewMessageReceivedNotification, object: nil)
    updateTableView()
  // Do any additional setup after loading the view.
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  

  // MARK: - Set Up

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
//    if searchText != "" {
//      filteredClients = clients.filter({
//        let currentClient = $0
//        return currentClient.fullName.lowercaseString.rangeOfString(searchText.lowercaseString) != nil
//      })
//      setUpSections(filteredClients!)
//    } else {
//      setUpSections(self.clients)
//      filteredClients = []
//      searchBar.performSelector("resignFirstResponder", withObject: nil, afterDelay: 0)
//    }
//    self.collectionView.reloadData()
//    searchBar.becomeFirstResponder()
  }

  // MARK: clients

  func loadClients(){
    let userManager = AMRUserManager()
    userManager.queryForAllClientsOfStylist(self.stylist!) { (arrayOfUsers, error) -> Void in
      if let error = error {
        print(error.localizedDescription)
      } else {
        self.clients = (arrayOfUsers as? [AMRUser])!
        self.clients = self.clients.sort{$0.firstName < $1.firstName}
        print(self.clients)
        self.collectionView.reloadData()
        AMRProfileImage.cache.cacheProfileImagesForClients(self.clients)
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

    let sectionHeaderNib = UINib(nibName: "AMRSectionCollectionReusableView", bundle: nil)
    collectionView.registerNib(sectionHeaderNib, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: kSectionHeaderReuseIdentifier)
    
    let todayCellNib = UINib(nibName: "AMRTodayTableCollectionViewCell", bundle: nil)
    collectionView.registerNib(todayCellNib, forCellWithReuseIdentifier: kTodayTableReuseIdentifier)
  }

  func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    searchbar.resignFirstResponder()
    collectionView.deselectItemAtIndexPath(indexPath, animated: true)
    let client = clients[indexPath.row]
    let clientDetailVC = AMRClientsDetailViewController(layerClient: layerClient)
    clientDetailVC.stylist = self.stylist
    clientDetailVC.client = client
    let nav = UINavigationController(rootViewController: clientDetailVC)
    self.presentViewController(nav, animated: true, completion: nil)

  }
  
  func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    if section == 0 {
      return 1
    } else {
      return clients.count
    }
  }


  func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    if indexPath.section == 0 {
      let cell = collectionView.dequeueReusableCellWithReuseIdentifier(kTodayTableReuseIdentifier, forIndexPath: indexPath) as! AMRTodayTableCollectionViewCell
      cell.updateData()
  
      cell.delegate = self
      return cell
    } else {
      let cell = collectionView.dequeueReusableCellWithReuseIdentifier("ClientCell", forIndexPath: indexPath) as! clientCollectionViewCell
      cell.client = clients[indexPath.row]
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
      return CGSize(width: collectionView.frame.size.width, height: 40 + 50)
    } else {
      return CGSize(width: collectionView.frame.size.width, height: 50)
    }
  }
  
  func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
    let view = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: kSectionHeaderReuseIdentifier, forIndexPath: indexPath) as! AMRSectionCollectionReusableView
    
    
    if indexPath.section == 0 {
      view.sectionTitleLabel.text = "Today"
    } else {
      view.sectionTitleLabel.text = "Clients"
    }
    
    return view
  }

  func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
    return 2
  }
  
  deinit {
    NSNotificationCenter.defaultCenter().removeObserver(self)
  }
}

extension AMRClientsViewController: AMRTodayTableCollectionViewCellDelegate{
  func todayTableCollectionViewCell(cell: AMRTodayTableCollectionViewCell, didSelectClient client: AMRUser) {
    if AMRBadgeManager.sharedInstance.clientBadges[client]?.isEqualTo(AMRClientBadges.hasUnreadMessagesOnly()) == true {
      presentConversationWithClient(client)
      return
    }
    
    let clientDetailVC = AMRClientsDetailViewController(layerClient: layerClient)
    clientDetailVC.stylist = self.stylist
    clientDetailVC.client = client
    let nav = UINavigationController(rootViewController: clientDetailVC)
    self.presentViewController(nav, animated: true, completion: nil)
  }
  
  private func presentConversationWithClient(client: AMRUser){
    let participants = [layerClient.authenticatedUserID, client.objectId, AMRUser.currentUser()!.objectId]
    let query = LYRQuery(queryableClass: LYRConversation.self)
    query.predicate = LYRPredicate(property: "participants", predicateOperator: LYRPredicateOperator.IsEqualTo, value: participants)
    layerClient.executeQuery(query) { (conversations, error) -> Void in
      if let error = error {
        NSLog("Query failed with error %@", error)
      } else if conversations.count <= 1 {
        let nc = UINavigationController(rootViewController: AMRMessagesDetailsViewController(layerClient: self.layerClient))
        let vc = nc.viewControllers.first as! AMRMessagesDetailsViewController
        vc.client = client
        vc.stylist = self.stylist
        let conversation = self.retrieveConversation(conversations, participants: participants)
        if let conversation = conversation {
          let shouldShowAddressBar: Bool  = conversation.participants.count > 2 || conversation.participants.count == 0
          vc.displaysAddressBar = shouldShowAddressBar
          vc.conversation = conversation
          self.presentViewController(nc, animated: true, completion: nil)
        } else {
          print("error occurred in transitioning to conversation detail, conversation nil")
        }
      } else {
        NSLog("%tu conversations with participants %@", conversations.count, participants)
      }
    }
  }
  
  private func retrieveConversation(conversations: NSOrderedSet, participants: [AnyObject]) -> LYRConversation? {
    var conversation: LYRConversation?
    if conversations.count == 1 {
      conversation = conversations[0] as? LYRConversation
    } else if conversations.count == 0{
      do {
        conversation = try self.layerClient.newConversationWithParticipants(NSSet(array: participants) as Set<NSObject>, options: nil)
        print("new conversation created since none existed")
      } catch let error {
        print("no conversations; conversation not created. error: \(error)")
      }
    }
    return conversation
  }
}
