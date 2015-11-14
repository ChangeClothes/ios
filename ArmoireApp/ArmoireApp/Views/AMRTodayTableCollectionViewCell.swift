//
//  AMRTodayTableCollectionViewCell.swift
//  ArmoireApp
//
//  Created by Randy Ting on 11/13/15.
//  Copyright © 2015 Armoire. All rights reserved.
//

import UIKit

protocol AMRTodayTableCollectionViewCellDelegate: class {
  func todayTableCollectionViewCell(cell: AMRTodayTableCollectionViewCell, didSelectClient client: AMRUser)
}

class AMRTodayTableCollectionViewCell: UICollectionViewCell {
  
  let kTodayTableViewCellReuseIdentifier = "com.armoire.TodayTableViewCellReuseIdentifier"
  
  @IBOutlet weak var todayTableView: UITableView!
  
  var clientsWithBadges = [AMRUser]()
  
  weak var delegate: AMRTodayTableCollectionViewCellDelegate?
  
  override func awakeFromNib() {
    todayTableView.delegate = self
    todayTableView.dataSource = self
    let cellNib = UINib(nibName: "AMRUpcomingMeetingsTableViewCell", bundle: nil)
    todayTableView.registerNib(cellNib, forCellReuseIdentifier: kTodayTableViewCellReuseIdentifier)
  }
 
  private func sortClientsWithBadges(clientBadgeData: [AMRUser: AMRClientBadges]) -> [AMRUser]{
    var resultArray = [AMRUser]()
    
    for (key, value) in clientBadgeData {
      resultArray.append(key)
    }
    
    return resultArray
  }
  
  func updateData(){
    clientsWithBadges = sortClientsWithBadges(AMRBadgeManager.sharedInstance.clientBadges)
    print(AMRBadgeManager.sharedInstance.clientBadges)
    todayTableView.reloadData()
  }
}

// MARK: - UITableViewDelegate
extension AMRTodayTableCollectionViewCell: UITableViewDelegate {
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    tableView.deselectRowAtIndexPath(indexPath, animated: true)
    delegate?.todayTableCollectionViewCell(self, didSelectClient: clientsWithBadges[indexPath.row])
  }
  
  
}

// MARK: - UITableViewDataSource
extension AMRTodayTableCollectionViewCell: UITableViewDataSource {
  func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 1
  }
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return clientsWithBadges.count
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier(kTodayTableViewCellReuseIdentifier, forIndexPath: indexPath) as! AMRUpcomingMeetingsTableViewCell
    
    cell.apptTitleTextLabel.text = clientsWithBadges[indexPath.row].firstName
    
    return cell
  }
}