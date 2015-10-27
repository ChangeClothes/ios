//
//  AMRClientsViewController.swift
//  ArmoireApp
//
//  Created by Morgan Wildermuth on 10/18/15.
//  Copyright © 2015 Armoire. All rights reserved.
//

import UIKit

class AMRClientsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, AMRViewControllerProtocol {
  
  @IBOutlet weak var clientTable: UITableView!
  var stylist: AMRUser?
  var client: AMRUser?
  var clients: [PFUser]?
  let cellConstant = "clientTableViewCellReuseIdentifier"

  override func viewDidLoad() {
    super.viewDidLoad()
    setUpClientTable()
    loadClients()
    self.title = "Clients"

    let settings: UIButton = UIButton()
    settings.setImage(UIImage(named: "settings"), forState: .Normal)
    settings.frame = CGRectMake(0, 0, 30, 30)
    settings.addTarget(self, action: Selector("onSettingsTap"), forControlEvents: .TouchUpInside)
    
    let leftNavBarButton = UIBarButtonItem(customView: settings)
    self.navigationItem.leftBarButtonItem = leftNavBarButton
    
    let addClient: UIButton = UIButton()
    addClient.setImage(UIImage(named: "plus"), forState: .Normal)
    addClient.frame = CGRectMake(0, 0, 30, 30)
    addClient.addTarget(self, action: Selector("onAddClientType"), forControlEvents: .TouchUpInside)

    let rightNavBarButton = UIBarButtonItem(customView: addClient)
    self.navigationItem.rightBarButtonItem = rightNavBarButton

  // Do any additional setup after loading the view.
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  func onSettingsTap(){
    let settingsVC = AMRSettingsViewController()
    self.presentViewController(settingsVC, animated: true, completion: nil)
  }
  
  func onAddClientType(){
    let addClientVC = AMRAddClientViewController()
    addClientVC.setVcData(self.stylist, client: nil)
    self.presentViewController(addClientVC, animated: true, completion: nil)
  }

  func loadClients(){
    let query : PFQuery = PFUser.query()!
    query.findObjectsInBackgroundWithBlock { (arrayOfUsers, error) -> Void in
      if let error = error {
        print(error.localizedDescription)
      } else {
        self.clients = arrayOfUsers as? [PFUser]
        self.clientTable.reloadData()
      }
    }
  }
  
  func setUpClientTable(){
    clientTable.delegate = self
    clientTable.dataSource = self
    let celNib = UINib(nibName: "AMRClientTableViewCell", bundle: nil)
    clientTable.registerNib(celNib, forCellReuseIdentifier: cellConstant)
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = clientTable.dequeueReusableCellWithIdentifier(cellConstant, forIndexPath: indexPath) as! AMRClientTableViewCell
    cell.client = clients![indexPath.row] as? AMRUser
    cell.textLabel!.text = clients![indexPath.row]["firstName"] as? String
    return cell
  }

  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    tableView.deselectRowAtIndexPath(indexPath, animated: true)
    let cell = clientTable.cellForRowAtIndexPath(indexPath) as! AMRClientTableViewCell
    let clientDetailVC = AMRClientsDetailViewController()
    clientDetailVC.stylist = self.stylist
    clientDetailVC.client = cell.client
    self.presentViewController(clientDetailVC, animated: true, completion: nil)
  }

  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if let clientList = self.clients {
      return clientList.count
    } else {
      return 0
    }
  }

  internal func setVcData(stylist: AMRUser?, client: AMRUser?) {
    self.stylist = stylist
    self.client = client
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
