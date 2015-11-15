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
  
  struct Calendar {
    static let currentCalendar = NSCalendar.currentCalendar()
  }
  
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
    var importanceScores = [AMRUser: Int]()
    for (key, value) in clientBadgeData {
      importanceScores[key] = importanceScoreForClient(key)
    }
    
    for (k,v) in (Array(importanceScores).sort {$0.1 > $1.1}) {
      print("\(k) , \(v)")
      resultArray.append(k)
    }
    
    return resultArray
  }
  
  private func importanceScoreForClient(client: AMRUser) -> Int {
    var score = 0
    
    for meeting in AMRBadgeManager.sharedInstance.meetingsToday {
      if meeting.client.objectId == client.objectId {
        let dateComponents = Calendar.currentCalendar.components([.Hour, .Minute], fromDate: meeting.startDate)
        let hour = dateComponents.hour
        let minutes = dateComponents.minute
        score += (100 * (24-hour)) + (60 - minutes)
      }
    }
    
    if AMRBadgeManager.sharedInstance.clientBadges[client]?.hasUnreadMessages == true {
      score += 1
    }
    
    return score
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