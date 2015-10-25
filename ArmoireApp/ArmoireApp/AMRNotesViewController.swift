//
//  AMRNotesViewController.swift
//  ArmoireApp
//
//  Created by Morgan Wildermuth on 10/18/15.
//  Copyright © 2015 Armoire. All rights reserved.
//

import UIKit

class AMRNotesViewController: UIViewController, AMRViewControllerProtocol{

  @IBOutlet weak var noteTextView: UITextView!
  var stylist: AMRUser?
  var client: AMRUser?
  var note: AMRNote?
  
  var startingText: String?
  
  override func viewWillAppear(animated: Bool) {
    loadNote()
    self.title = "Notes"
    var settings: UIButton = UIButton()
    settings.setImage(UIImage(named: "settings"), forState: .Normal)
    settings.frame = CGRectMake(0, 0, 30, 30)
    settings.addTarget(self, action: Selector("onSettingsTap"), forControlEvents: .TouchUpInside)
    var leftNavBarButton = UIBarButtonItem(customView: settings)
    self.navigationItem.leftBarButtonItem = leftNavBarButton
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view.
  }
  
  override func viewDidDisappear(animated: Bool) {
    if (startingText != noteTextView.text){
      //update Parse object
      note?.setObject(noteTextView.text, forKey: "content")
      note?.saveInBackground()
    }
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  func onSettingsTap(){
    let settingsVC = AMRSettingsViewController()
    self.presentViewController(settingsVC, animated: true, completion: nil)
  }
  
  func loadNote(){
    AMRNote.noteForUser(AMRUser.currentUser(), client: AMRUser.currentUser()) { (objects, error) -> Void in
      if let error = error {
        print(error.localizedDescription)
      } else if (objects!.isEmpty) {
        // handle there being no note; create initial note
        self.createNote()
      } else if let notes = objects {
        if (notes.count > 1 ){
          // problem because there is more than one note associated with this user
        } else {
          // no problems, here be your note
          self.note = notes[0]
          self.startingText = self.note?.content
          self.noteTextView.text = self.note?.content
        }
      }
    }
  }
  
  func flushVCData() {
    note = nil
    stylist = nil
    client = nil
  }
  
  func setVCData(stylist: AMRUser?, client: AMRUser?) {
//    loadNote()
//    self.stylist = stylist
//    self.client = client
  }
  
  private func createNote(){
    var note = PFObject(className: "Note")
    note.setObject(AMRUser.currentUser()!, forKey: "client")
    note.setObject(AMRUser.currentUser()!, forKey: "stylist")
    note.saveInBackgroundWithBlock { (success, error) -> Void in
      if success {
        NSLog("Note created")
        self.loadNote()
      } else {
        NSLog("%@", error!)
      }
    }
  }

  internal func setVcData(stylist: AMRUser?, client: AMRUser?) {
    self.stylist = stylist
    self.client = client
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
