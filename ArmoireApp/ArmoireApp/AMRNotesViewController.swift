//
//  AMRNotesViewController.swift
//  ArmoireApp
//
//  Created by Morgan Wildermuth on 10/18/15.
//  Copyright © 2015 Armoire. All rights reserved.
//

import UIKit

class AMRNotesViewController: AMRViewController, UITextViewDelegate{

  @IBOutlet weak var noteTextView: UITextView!
  var note: AMRNote?
  var photoPicker: PhotoPicker?
  
  @IBOutlet weak var constraintTextViewToBottom: NSLayoutConstraint!
  var startingText: String?
  
  // MARK: - Lifecycle

  override func viewWillAppear(animated: Bool) {
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillChangeFrameNotification, object: nil)
    loadNote()
    self.title = "Notes"
    noteTextView.delegate = self
    setUpNavBar()
    setUpUI()
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view.
  }
  
  override func viewWillDisappear(animated: Bool){
    super.viewWillDisappear(false)
    saveNote()
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  // MARK: - Setup


  private func setUpUI(){
    let backgroundImage = UIImage(named: "note-background")!
    UIGraphicsBeginImageContextWithOptions(self.noteTextView.frame.size, false, 0.0)
    backgroundImage.drawInRect(CGRectMake(0.0, 0.0, self.noteTextView.frame.size.width, self.noteTextView.frame.size.height))
    let resultImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    self.noteTextView.backgroundColor = UIColor(patternImage: resultImage)
    self.view.backgroundColor = UIColor(patternImage: resultImage)
  }
  
  private func setUpNavBar(){
    createNavBarButtonItems()
 }

  private func loadNote(){
    AMRNote.noteForUser(self.stylist, client: self.client) { (objects, error) -> Void in
      if let error = error {
        print(error.localizedDescription)
      } else if (objects!.isEmpty) {
        // handle there being no note; create initial note
        self.createNote()
      } else if let notes = objects {
        if (notes.count > 1 ){
          print("more than one note associated in this context")
        } else {
          // no problems, here be your note
          self.note = notes[0]
          self.startingText = self.note?.content
          self.noteTextView.text = self.note?.content
        }
      }
    }
  }

  // MARK: - On Tap Actions

  func exitModal(){
    self.dismissViewControllerAnimated(true, completion: nil)
  }

  func onSettingsTap(){
    showSettings()
  }

  func onDoneEditingTap(){
    textViewDidEndEditing(noteTextView)
  }

  // MARK: - AMRViewController Protocol Compliance
  
  func flushVCData() {
    note = nil
    stylist = nil
    client = nil
  }
  
  func setVCData(stylist: AMRUser?, client: AMRUser?) {
    self.stylist = stylist
    self.client = client
    loadNote()
  }


  // MARK: - Background Actions

  func textViewDidBeginEditing(textView: UITextView) {
    createDoneEditingButton()
    self.navigationItem.leftBarButtonItem = nil
  }

  func textViewDidEndEditing(textView: UITextView) {
    noteTextView.resignFirstResponder()
    moveNoteDown()
    self.navigationItem.rightBarButtonItem = nil
    createNavBarButtonItems()
    saveNote()
  }

  private func createNote(){
    let note = PFObject(className: "Note")
    if let client = self.client {
      note.setObject(client, forKey: "client")
    }
    if let stylist = self.stylist {
      note.setObject(stylist, forKey: "stylist")
    }
    note.saveInBackgroundWithBlock { (success, error) -> Void in
      if success {
        NSLog("Note created")
        self.loadNote()
      } else {
        NSLog("%@", error!)
      }
    }
  }

  private func saveNote(){
    if (startingText != noteTextView.text){
      note?.setObject(noteTextView.text, forKey: "content")
      note?.saveInBackground()
    }
  }

  private func moveNoteUp(keyboardHeight: CGFloat?){
    self.constraintTextViewToBottom.constant = keyboardHeight! - (self.navigationController?.navigationBar.frame.height)! - UIApplication.sharedApplication().statusBarFrame.size.height - 5.0
    self.view.layoutIfNeeded()
  }

  private func moveNoteDown(){
    self.constraintTextViewToBottom.constant = 0
    self.view.layoutIfNeeded()
  }

  // MARK: - Create Nav Bar Button Items

  private func createNavBarButtonItems(){
    if (stylist != nil && client != nil){
      createExitModalButton()
    } else {
      createSettingsButton()
    }
  }

  private func createDoneEditingButton(){
    let doneButton: UIButton = UIButton()
    doneButton.setImage(UIImage(named: "check"), forState: .Normal)

    doneButton.frame = CGRectMake(0, 0, 30, 30)
    doneButton.addTarget(self, action: Selector("onDoneEditingTap"), forControlEvents: .TouchUpInside)

    let rightNavBarButton = UIBarButtonItem(customView: doneButton)
    self.navigationItem.rightBarButtonItem = rightNavBarButton
  }

  private func createExitModalButton(){
    let leftNavBarButton = UIBarButtonItem(image: UIImage(named: "cancel"), style: .Plain, target: self, action: "exitModal")
    self.navigationItem.leftBarButtonItem = leftNavBarButton
  }

  private func createSettingsButton(){
    let leftNavBarButton = UIBarButtonItem(image: UIImage(named: "settings"), style: .Plain, target: self, action: "onSettingsTap")
    self.navigationItem.leftBarButtonItem = leftNavBarButton
  }

  // MARK - Observer Actions

  func keyboardWillShow(notification: NSNotification){
    let userInfo = notification.userInfo as? NSDictionary
    let endLocationOfKeyboard = userInfo?[UIKeyboardFrameEndUserInfoKey]?.CGRectValue
    let size = endLocationOfKeyboard?.size
    let keyboardHeight = size?.height
    moveNoteUp(keyboardHeight)
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
