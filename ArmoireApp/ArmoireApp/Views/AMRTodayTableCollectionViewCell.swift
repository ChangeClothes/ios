//
//  AMRTodayTableCollectionViewCell.swift
//  ArmoireApp
//
//  Created by Randy Ting on 11/13/15.
//  Copyright © 2015 Armoire. All rights reserved.
//

import UIKit

class AMRTodayTableCollectionViewCell: UICollectionViewCell {
  
  let kTodayTableViewCellReuseIdentifier = "com.armoire.TodayTableViewCellReuseIdentifier"
  
  @IBOutlet weak var todayTableView: UITableView!
  
  let values = [
  "one",
    "two",
    "three",
    "FOUR",
    "FIVE",
  ]
  
  override func awakeFromNib() {
    todayTableView.delegate = self
    todayTableView.dataSource = self
    let cellNib = UINib(nibName: "AMRUpcomingMeetingsTableViewCell", bundle: nil)
    todayTableView.registerNib(cellNib, forCellReuseIdentifier: kTodayTableViewCellReuseIdentifier)
  }
  
}

extension AMRTodayTableCollectionViewCell: UITableViewDelegate {
  
}

extension AMRTodayTableCollectionViewCell: UITableViewDataSource {
  func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 1
  }
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return values.count
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier(kTodayTableViewCellReuseIdentifier, forIndexPath: indexPath)
    
    
    
    return cell
  }
}