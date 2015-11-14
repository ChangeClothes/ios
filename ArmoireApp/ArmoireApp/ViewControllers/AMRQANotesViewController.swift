//
//  AMRQANotesViewController.swift
//  ArmoireApp
//
//  Created by Mathew Kellogg on 11/8/15.
//  Copyright © 2015 Armoire. All rights reserved.
//

import UIKit

class AMRQANotesViewController: AMRViewController, UITableViewDataSource, UITableViewDelegate, UITextViewDelegate {
  
  @IBOutlet weak var tableView: UITableView!
  var note: AMRNote?
  var questionAnswers: AMRQuestionAnswer?
  var heights: [CGFloat]?
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    return buildCell(tableView, indexPath: indexPath)
  }
  
  func buildCell(tableview: UITableView, indexPath: NSIndexPath) -> UITableViewCell {
    print("section", indexPath.section, "row", indexPath.row)
    
    if indexPath.row == 0 && client != nil{ // return notes cell
      let cell = tableView.dequeueReusableCellWithIdentifier(AMRNoteTableViewCell.cellReuseIdentifier()) as! AMRNoteTableViewCell
      cell.contents.text = note?.content
      cell.contents.delegate = self
      return cell
    }
    
    let isNotesOffset = client == nil ? 0 : 1
    
    //return QA cell
    let cell = tableView.dequeueReusableCellWithIdentifier(AMRQuestionAnswerTableViewCell.cellReuseIdentifier()) as! AMRQuestionAnswerTableViewCell
    let qa = questionAnswers?.qas![indexPath.row - isNotesOffset]
    cell.question.text = qa!["question"]
    if client != nil {
      cell.answer.text = qa!["answer"]
    } else {
      cell.answer.hidden = true
      cell.answer.text = ""
    }
    cell.answer.delegate = self
    
    return cell
  }
  
  func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    return AMRDynamicHeightTableViewCell.getDefaultHeight()
  }
  
  func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    if let rowHeights = heights{
      return rowHeights[indexPath.row]
    }
    return AMRDynamicHeightTableViewCell.getDefaultHeight()
  }
  
  func numberOfRows() -> Int {
    var count = 0
    if let qa = questionAnswers {
      count += qa.qas!.count
    }
    if client != nil {
      count += 1
    }
    print("returning count:", count)
    return count
  }
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return numberOfRows()
  }
  
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    tableView.deselectRowAtIndexPath(indexPath, animated: true)
  }
  
  func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
    return CGFloat(0)
  }
  
  func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return CGFloat(0)
  }
  
  
  func textViewDidChange(textView: UITextView)
  {
    let indexPath = tableView.indexPathForRowAtPoint(textView.superview!.superview!.center)
    let cell = tableView.cellForRowAtIndexPath(indexPath!) as! AMRDynamicHeightTableViewCell
    let height = cell.getCellHeight(nil)
    if indexPath!.row != 0 {
      textView.textAlignment = .Right  // for some reason it defaults back to left on typing
    }
    print("text did change for row", indexPath?.row, textView.center, height)

    if heights![indexPath!.row] != height {
      tableView.beginUpdates()
      heights![indexPath!.row] = cell.getCellHeight(nil)
      tableView.endUpdates()
    }
  }
  
  func textViewDidBeginEditing(textView: UITextView) {
  }
  
  func textViewDidEndEditing(textView: UITextView) {
      self.questionAnswers?.saveInBackground()
  }
  
  func updateData(){
    calculateRowHeights()
    self.tableView.reloadData()
    print("heights", heights)
    print("note", note)
    print("qa", questionAnswers!.qas, questionAnswers!.qas!.count)
  }
  
  func getCellHeight(index:Int) -> CGFloat{
    let indexPath = NSIndexPath(forRow: index, inSection: 0)
    let cell = buildCell(tableView, indexPath: indexPath) as! AMRDynamicHeightTableViewCell
    return cell.getCellHeight(tableView.frame.width)
  }
  
  func calculateRowHeights(){
    let numRows =  self.numberOfRows()
    heights = [CGFloat]( count: numRows , repeatedValue: AMRDynamicHeightTableViewCell.getDefaultHeight())
    if numRows > 0 {
      for index in 0...numRows - 1 {
        print("calculating row height for row", index)
        heights![index] = getCellHeight(index)
      }
    }
  }
  
  func getData(){
    
    var noteLoaded = false
    var questionAnswerLoaded = false
    
    if client != nil {
      AMRQuestionAnswer.getOrCreateForUser(self.stylist!, client: self.client) { (questionAnswer, error) -> Void in
        self.questionAnswers = questionAnswer
        questionAnswerLoaded = true
        if noteLoaded && questionAnswerLoaded {
          self.updateData()
        }
      }
    } else {
      AMRQuestionAnswer.getTemplate(self.stylist, completion: { (template, error) -> Void in
        self.questionAnswers = template
        questionAnswerLoaded = true
        if noteLoaded && questionAnswerLoaded {
          self.updateData()
        }
      })
    }
    
    AMRNote.getOrCreateNoteForUser(stylist, client: client) { (note, error) -> Void in
      self.note = note
      noteLoaded = true
      print(noteLoaded, questionAnswerLoaded)
      if noteLoaded && questionAnswerLoaded {
        self.updateData()
      }
    }
    
  }
  
  func addQuestionAnswer(){
    let alertController = UIAlertController(title: "Choose Question:", message: "Type the text of the new question you'd like to add.", preferredStyle: .Alert)
    alertController.view.tintColor = UIColor.AMRSecondaryBackgroundColor()
    let addAction = UIAlertAction(title: "Add", style: .Default) { (action) in
      let questionTextField = alertController.textFields![0] as UITextField
      self.questionAnswers?.qas!.append(["question": questionTextField.text!, "answer":""])
      self.updateData()
      self.questionAnswers?.saveInBackground()
    }
    let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (action) in }
    
    alertController.addTextFieldWithConfigurationHandler { (textField: UITextField) -> Void in
      textField.placeholder = "type your question here"
    }
    alertController.addAction(addAction)
    alertController.addAction(cancelAction)
    
    self.presentViewController(alertController, animated: true){}
  }
  
  func exitModal(){
    NSNotificationCenter.defaultCenter().postNotificationName(kDismissedModalNotification, object: self)
    self.dismissViewControllerAnimated(true, completion: nil)
  }
  
  internal func setUpNavBar(){
    if (stylist != nil && client != nil){
      let leftNavBarButton = UIBarButtonItem(image: UIImage(named: "cancel"), style: .Plain, target: self, action: "exitModal")
      self.navigationItem.leftBarButtonItem = leftNavBarButton
    } else {
      let leftNavBarButton = UIBarButtonItem(image: UIImage(named: "settings"), style: .Plain, target: self, action: "onSettingsTap")
      self.navigationItem.leftBarButtonItem = leftNavBarButton
    }
    if (client != nil){
      self.title = (client?.firstName)! + " " + (client?.lastName)!
    } else {
      self.title = "Template Builder"
    }
    if CurrentUser.sharedInstance.user?.isStylist == true {
      let rightNavBarButton = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "addQuestionAnswer")
      self.navigationItem.rightBarButtonItem = rightNavBarButton
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.tableView.separatorStyle = .None
    if client != nil {
      self.automaticallyAdjustsScrollViewInsets = false
    }
    
    //start fetching data
    getData()
    setUpNavBar()
    
    //set up table
    tableView.delegate = self
    tableView.dataSource = self
    var cellNib = UINib(nibName: "AMRNoteTableViewCell", bundle: nil)
    tableView.registerNib(cellNib, forCellReuseIdentifier: AMRNoteTableViewCell.cellReuseIdentifier())
    cellNib = UINib(nibName: "AMRQuestionAnswerTableViewCell", bundle: nil)
    tableView.registerNib(cellNib, forCellReuseIdentifier: AMRQuestionAnswerTableViewCell.cellReuseIdentifier())
    
    
    // Do any additional setup after loading the view.
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
}
