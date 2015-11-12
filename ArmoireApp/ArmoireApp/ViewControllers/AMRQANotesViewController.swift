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
    
    if indexPath.row == 0 { // return notes cell
      let cell = tableView.dequeueReusableCellWithIdentifier(AMRNoteTableViewCell.cellReuseIdentifier()) as! AMRNoteTableViewCell
      cell.contents.text = note?.content
      cell.contents.delegate = self
      return cell
    }
    
    //return QA cell
    let cell = tableView.dequeueReusableCellWithIdentifier(AMRQuestionAnswerTableViewCell.cellReuseIdentifier()) as! AMRQuestionAnswerTableViewCell
    let qa = questionAnswers?.qas![indexPath.row - 1]
    cell.question.text = qa!["question"]
    cell.answer.text = qa!["answer"]
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
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if let qa = questionAnswers {
      return qa.qas!.count + 1
    }
    return 1
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
    print("text did changec for row", indexPath?.row, textView.center, height)

    if heights![indexPath!.row] != height {
      tableView.beginUpdates()
      heights![indexPath!.row] = cell.getCellHeight(nil)
      tableView.endUpdates()
    }
  }
  
  func textViewDidBeginEditing(textView: UITextView) {
    
  }
  
  func textViewDidEndEditing(textView: UITextView) {
    
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
    heights = [CGFloat]( count: (questionAnswers?.qas!.count)! + 1, repeatedValue: AMRDynamicHeightTableViewCell.getDefaultHeight())
    for index in 0...(self.questionAnswers!.qas!.count) {
      print("calculating row height for row", index)
      heights![index] = getCellHeight(index)
    }
  }
  
  func getData(){
    
    var noteLoaded = false
    var questionAnswerLoaded = false
    
    AMRQuestionAnswer.getOrCreateForUser(self.stylist!, client: self.client) { (questionAnswer, error) -> Void in
      questionAnswer!.qas = [
        ["question": "What is your face?", "answer": "My face is a face like any face. FACE!"],
        ["question": "What what do you think of this question? is it way too long? why are there so many parts?", "answer": "Yes, you should definitely make it shorter this is just ridiculous, why would you have a cell that size? \nOH NO WHY ISN'T THIS SHOWING UP!?@?@?@?@?@?\n"]
      ]
      self.questionAnswers = questionAnswer
      questionAnswerLoaded = true
      print(noteLoaded, questionAnswerLoaded)
      if noteLoaded && questionAnswerLoaded {
        self.updateData()
      }
    }
    
    AMRNote.getOrCreateNoteForUser(stylist, client: client) { (note, error) -> Void in
      note!.content = "I am a note, note, note.\nNOTTTEEEEEESSSSS\nnote\nnote\nnote\nnote\nnote\nnote\nnote"
      self.note = note
      noteLoaded = true
      print(noteLoaded, questionAnswerLoaded)
      if noteLoaded && questionAnswerLoaded {
        self.updateData()
      }
    }
    
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
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.tableView.separatorStyle = .None
    //self.navigationController?.setNavigationBarHidden(true, animated: false)
    
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
