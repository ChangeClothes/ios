//
//  AMRClientsViewController.swift
//  ArmoireApp
//
//  Created by Morgan Wildermuth on 10/18/15.
//  Copyright © 2015 Armoire. All rights reserved.
//

import UIKit

class AMRClientsViewController: AMRViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UIGestureRecognizerDelegate {

  // MARK: - Outlets
  
  @IBOutlet weak var clientTable: UITableView!

  // MARK: - Constants

  let cellConstant = "clientTableViewCellReuseIdentifier"

  // MARK: - Properties

  var tap: UITapGestureRecognizer!
  var searchbar = UISearchBar(frame: CGRect(x: 0.0, y: 0.0, width: 280.0, height: 44.0))
  var layerClient: LYRClient!
  var sections = [String]()
  var clientSections = [String:[AMRUser]]()
  var filteredClients: [AMRUser]?
  var clients: [AMRUser]?
  var searchActive = false

  // MARK: - Lifecycle

  convenience init(layerClient: LYRClient){
    self.init()
    self.layerClient = layerClient
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    setUpClientTable()
    loadClients()
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

  func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
    searchbar.resignFirstResponder()
    return false
  }

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
      filteredClients = clients!.filter({
        let currentClient = $0
        return currentClient.fullName.lowercaseString.rangeOfString(searchText.lowercaseString) != nil
      })
      setUpSections(filteredClients!)
    } else {
      setUpSections(self.clients!)
      filteredClients = []
    }
    self.clientTable.reloadData()
  }

  func loadClients(){
    let userManager = AMRUserManager()
    userManager.queryForAllClientsOfStylist(self.stylist!) { (arrayOfUsers, error) -> Void in
      if let error = error {
        print(error.localizedDescription)
      } else {
        self.clients = arrayOfUsers as? [AMRUser]
        self.setUpSections(self.clients!)
        self.clientTable.reloadData()
      }
    }
  }

  func setUpClientTable(){
    clientTable.delegate = self
    clientTable.dataSource = self
    clientTable.sectionIndexColor = UIColor.AMRBrightButtonTintColor()
    //let header:UITableViewHeaderFooterView = clientTable as! UITableViewHeaderFooterView
    //header.textLabel!.textColor = UIColor.AMRUnselectedTabBarButtonTintColor()
    //header.contentView.backgroundColor = UIColor.AMRSecondaryBackgroundColor()
    searchbar.delegate = self
    searchbar.searchBarStyle = UISearchBarStyle.Minimal
    self.view.addSubview(searchbar)
    clientTable.tableHeaderView = searchbar;
    let celNib = UINib(nibName: "AMRClientTableViewCell", bundle: nil)
    clientTable.registerNib(celNib, forCellReuseIdentifier: cellConstant)
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = clientTable.dequeueReusableCellWithIdentifier(cellConstant, forIndexPath: indexPath) as! AMRClientTableViewCell
    cell.client = clientSections[sections[indexPath.section]]![indexPath.row]
    cell.textLabel!.text = cell.client?.fullName
    return cell
  }

  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    tableView.deselectRowAtIndexPath(indexPath, animated: true)
    let cell = clientTable.cellForRowAtIndexPath(indexPath) as! AMRClientTableViewCell
    let clientDetailVC = AMRClientsDetailViewController(layerClient: layerClient)
    clientDetailVC.stylist = self.stylist
    clientDetailVC.client = cell.client
    let nav = UINavigationController(rootViewController: clientDetailVC)
    let formSheetController = MZFormSheetPresentationViewController(contentViewController: nav)
    let viewHeight = self.view.frame.height - 40
    let viewWidth = self.view.frame.width - 25
    formSheetController.presentationController?.contentViewSize = CGSizeMake(viewWidth, viewHeight)
    self.presentViewController(formSheetController, animated: true, completion: nil)
  }

  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if sections.count == 0 {
      return 0
    } else {
      return clientSections[sections[section]]!.count
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
  
  
  func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return sections.count
  }
  
  func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    return sections[section]
  }
  
  func sectionIndexTitlesForTableView(tableView: UITableView) -> [String]? {
    return sections
  }
  
  func tableView(tableView: UITableView, sectionForSectionIndexTitle title: String, atIndex index: Int) -> Int {
    return index
  }
  
}
