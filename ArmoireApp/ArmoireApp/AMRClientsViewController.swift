//
//  AMRClientsViewController.swift
//  ArmoireApp
//
//  Created by Morgan Wildermuth on 10/18/15.
//  Copyright © 2015 Armoire. All rights reserved.
//

import UIKit

class AMRClientsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
  
  @IBOutlet weak var clientTable: UITableView!
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
  
  func loadClients(){
    let query : PFQuery = PFUser.query()!
    query.findObjectsInBackgroundWithBlock { (arrayOfUsers, error) -> Void in
        self.clients = arrayOfUsers as? [PFUser]
        self.clientTable.reloadData()
    }
  }
  
  func setUpClientTable(){
    clientTable.delegate = self
    clientTable.dataSource = self
    let celNib = UINib(nibName: "AMRClientTableViewCell", bundle: nil)
    clientTable.registerNib(celNib, forCellReuseIdentifier: cellConstant)
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = clientTable.dequeueReusableCellWithIdentifier(cellConstant, forIndexPath: indexPath)
    cell.textLabel!.text = clients![indexPath.row]["firstName"] as? String
    return cell
  }

  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    tableView.deselectRowAtIndexPath(indexPath, animated: true)
    let clientDetailVC = AMRClientsDetailViewController()
    self.presentViewController(clientDetailVC, animated: true, completion: nil)
  }

  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if let clientList = self.clients {
      return clientList.count
    } else {
      return 0
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
