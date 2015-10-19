//
//  AMRClientsViewController.swift
//  ArmoireApp
//
//  Created by Morgan Wildermuth on 10/18/15.
//  Copyright © 2015 Armoire. All rights reserved.
//

import UIKit

class AMRClientsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
  
    var clients: NSDictionary?

    override func viewDidLoad() {
        super.viewDidLoad()
      self.title = "Clients"

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    //need to deque from table; planning to switch over to different view than table so wait
    return AMRClientTableViewCell()
  }
  
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
//    let cell = tweetTable.cellForRowAtIndexPath(indexPath) as! TweetTableViewCell
//    performSegueWithIdentifier("segueToTweet", sender: cell)
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
