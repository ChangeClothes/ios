//
//  AMRMessagesViewController.swift
//  ArmoireApp
//
//  Created by Morgan Wildermuth on 10/18/15.
//  Copyright © 2015 Armoire. All rights reserved.
//

import UIKit

class AMRMessagesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    var messages: NSDictionary?
    @IBOutlet weak var messagesTable: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Messages"
        
//        var btnName: UIButton = UIButton()
//        btnName.setImage(UIImage(named: "settings"), forState: .Normal)
//        btnName.frame = CGRectMake(0, 0, 30, 30)
//        btnName.backgroundColor = UIColor.blackColor()
//        btnName.addTarget(self, action: Selector("action"), forControlEvents: .TouchUpInside)
//        
//        //.... Set Right/Left Bar Button item
//        var rightBarButton:UIBarButtonItem = UIBarButtonItem()
//        rightBarButton.customView = btnName
//        self.navigationItem.rightBarButtonItem = rightBarButton
//
//        self.view.addSubview(btnName);
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
      //need to deque from table; planning to switch over to different view than table so wait
        let cell = messagesTable.dequeueReusableCellWithIdentifier("MessageCell", forIndexPath: indexPath) as! AMRMessageTableViewCell
        return cell
    }
  
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let messageList = self.messages {
          return messageList.count
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
