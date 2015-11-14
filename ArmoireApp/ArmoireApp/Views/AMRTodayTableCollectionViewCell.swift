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
    let cellNib = UINib(nibName: "AMRTodayTableViewCell", bundle: nil)
    todayTableView.registerNib(cellNib, forCellReuseIdentifier: kTodayTableViewCellReuseIdentifier)
    todayTableView.rowHeight = 90
    todayTableView.estimatedRowHeight = 90
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
    let cell = tableView.dequeueReusableCellWithIdentifier(kTodayTableViewCellReuseIdentifier, forIndexPath: indexPath) as! AMRTodayTableViewCell
    
    let client = clientsWithBadges[indexPath.row]
    let badges = AMRBadgeManager.sharedInstance.clientBadges[client]
    
    client.fetchIfNeededInBackgroundWithBlock{ (user: PFObject?, error: NSError?) -> Void in
      if let error = error {
        print(error.localizedDescription)
      } else {
        cell.avatarImage.layer.cornerRadius = cell.avatarImage.frame.width/2
        cell.avatarImage.clipsToBounds = true
        cell.avatarImage.setAMRImage((user as! AMRUser).profilePhoto, withPlaceholder: "profile-image-placeholder")
      }
    }
    cell.nameLabel.text = client.firstName + " " + client.lastName
    cell.appointmentsLabelHeightConstraint.constant = 0
    cell.newMessagesLabelHeightConstraint.constant = 0
    cell.unratedPhotosHeightConstraint.constant = 0
    
    if badges?.hasMeetingToday == true {
      cell.appointmentsLabelHeightConstraint.constant = 16
    }
    if badges?.hasUnreadMessages == true {
      cell.newMessagesLabelHeightConstraint.constant = 16
    }
    if badges?.hasUnratedPhotos == true {
      cell.unratedPhotosHeightConstraint.constant = 16
    }
    
    
    
    return cell
  }
}