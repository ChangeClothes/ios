//
//  AMRQANotesViewController.swift
//  ArmoireApp
//
//  Created by Mathew Kellogg on 11/8/15.
//  Copyright © 2015 Armoire. All rights reserved.
//

import UIKit

class AMRQANotesViewController: AMRViewController, UITableViewDataSource, UITableViewDelegate, UITextViewDelegate{

  @IBOutlet weak var tableView: UITableView!
  var note: AMRNote?
  var questionAnswers: AMRQuestionAnswer?
  var noteHeight = CGFloat(100);
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    
    if indexPath.row == 0 { // return notes cell
      let cell = tableView.dequeueReusableCellWithIdentifier(AMRNoteTableViewCell.cellReuseIdentifier(), forIndexPath: indexPath) as! AMRNoteTableViewCell
      cell.contents.text = note?.content
      cell.contents.delegate = self
      return cell
    }
    
    //return QA cell
    let cell = tableView.dequeueReusableCellWithIdentifier(AMRQuestionAnswerTableViewCell.cellReuseIdentifier(), forIndexPath: indexPath) as! AMRQuestionAnswerTableViewCell
    let qa = questionAnswers?.qas![indexPath.row - 1]
    cell.question.text = qa!["question"]
    cell.answer.text = qa!["answer"]
    
    return cell
  }
  
  //func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
  //  if indexPath.row == 0 {
  //    return CGFloat(noteHeight) + 16
  //  }
  //}
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if let qa = questionAnswers {
      return qa.qas!.count + 1
    }
    return 1
  }
  
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    tableView.deselectRowAtIndexPath(indexPath, animated: true)
  }
  
  func textViewDidChange(textView: UITextView)
  {
    tableView.beginUpdates()
    print(textView.text)
    let fixedWidth : CGFloat = textView.frame.size.width
    let newSize : CGSize = textView.sizeThatFits(CGSizeMake(fixedWidth, CGFloat(MAXFLOAT)))
    var newFrame : CGRect = textView.frame
    newFrame.size = CGSizeMake(CGFloat(fmaxf((Float)(newSize.width), (Float)(fixedWidth))),newSize.height)
    textView.frame = newFrame
    noteHeight = newSize.height
    print(newSize.height)
    
    //tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: 0, inSection: 0)], withRowAnimation: UITableViewRowAnimation.Automatic)
    tableView.endUpdates()
  }
  
  func textViewDidBeginEditing(textView: UITextView) {
    
  }
  
  func textViewDidEndEditing(textView: UITextView) {
    
  }
  
  func getData(){
    
    var noteLoaded = false
    var questionAnswerLoaded = false
    
    AMRQuestionAnswer.getOrCreateForUser(self.stylist!, client: self.client) { (questionAnswer, error) -> Void in
      questionAnswer!.qas = [
        ["question": "What is your face?", "answer": "My face is a face like any face. FACE!"],
        ["question": "What what do you think of this question? is it way too long? why are there so many parts?", "answer": "Yes, you should definitely make it shorter this is just ridiculous, why would you have a cell that size?"]
      ]
      self.questionAnswers = questionAnswer
      questionAnswerLoaded = true
      if noteLoaded && questionAnswerLoaded {
        self.tableView.reloadData()
      }
    }
    
    AMRNote.getOrCreateNoteForUser(stylist, client: client) { (note, error) -> Void in
      note!.content = "I am a note, note, note.\nNOTTTEEEEEESSSSS\nnote\nnote\nnote\nnote\nnote\nnote\nnote"
      self.note = note
      noteLoaded = true
      if noteLoaded && questionAnswerLoaded {
        self.tableView.reloadData()
      }
    }
    
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    //start fetching data
    getData()
    
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
