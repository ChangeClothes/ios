//
//  AMRQANotesViewController.swift
//  ArmoireApp
//
//  Created by Mathew Kellogg on 11/8/15.
//  Copyright © 2015 Armoire. All rights reserved.
//

import UIKit

class AMRQANotesViewController: AMRViewController, UITableViewDataSource, UITableViewDelegate {

  @IBOutlet weak var tableView: UITableView!
  var note: AMRNote?
  var questionAnswers: AMRQuestionAnswer?
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    if indexPath.row == 0 {
      let cell = tableView.dequeueReusableCellWithIdentifier(, forIndexPath: <#T##NSIndexPath#>)
    }
  }
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if let qa = questionAnswers {
      return qa.qas!.count + 2
    }
    return 2
  }
  
  func getData(){
    
    AMRQuestionAnswer.getOrCreateForUser(self.stylist!, client: self.client) { (questionAnswer, error) -> Void in
      self.questionAnswers = questionAnswer
    }
    
    AMRNote.getOrCreateNoteForUser(stylist, client: client) { (note, error) -> Void in
      self.note = note
    }
    
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    getData()
    
    // Do any additional setup after loading the view.
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  

}
