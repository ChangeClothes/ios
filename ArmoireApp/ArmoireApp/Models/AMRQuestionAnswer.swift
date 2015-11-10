//
//  AMRQuestionAnswer.swift
//  ArmoireApp
//
//  Created by Mathew Kellogg on 11/8/15.
//  Copyright © 2015 Armoire. All rights reserved.
//

class AMRQuestionAnswer: PFObject {
  
  @NSManaged var qas: [[String:String]]?
  @NSManaged var client: AMRUser?
  @NSManaged var stylist: AMRUser?
  
  class func getOrCreateForUser(stylist: AMRUser, client: AMRUser?, completion: (questionAnswer: AMRQuestionAnswer?, error: NSError?) -> Void) {
    
    let query = self.query()
    query?.whereKey("stylist", equalTo: stylist)
    
    if let client = client {
      query?.whereKey("client", equalTo: client)
    } else {
      query?.whereKeyDoesNotExist("client")
    }
    
    query?.findObjectsInBackgroundWithBlock({ (objects: [PFObject]?, error: NSError?) -> Void in
      
      if error != nil {
        completion(questionAnswer:nil , error: error)
      }
      
      if objects?.count == 0 {
        getTemplate(stylist) { (questionAnswer: AMRQuestionAnswer?, error: NSError?) -> Void in
          
          if error != nil {
            completion(questionAnswer:nil , error: error)
          }
          
          let qa = AMRQuestionAnswer()
          qa.stylist = stylist
          qa.client = client
          qa.qas = questionAnswer!.qas
          qa.saveInBackground()
          completion(questionAnswer: qa, error: nil)
          
        }
      } else {
        let qa = objects!.first as! AMRQuestionAnswer
        completion(questionAnswer:qa , error: nil)
      }
      
    })
  }
  
  class func getTemplate(stylist: AMRUser?, completion: (template: AMRQuestionAnswer?, error: NSError?) -> Void) {
    
    let query = self.query()
    
    query?.whereKey("stylist", equalTo: stylist!)
    query?.whereKeyDoesNotExist("client")
   
    query?.findObjectsInBackgroundWithBlock(){ (objects: [PFObject]?, error: NSError?) -> Void in
    if error != nil {
      completion(template:nil , error: error)
    }
       
      if let templates = objects {
        if templates.count == 0 {
          let template = AMRQuestionAnswer()
          template.stylist = stylist
          template.qas = [[String:String]()]
          completion(template: template, error: nil)
        } else {
          let template = templates.first as! AMRQuestionAnswer
          completion(template: template, error: nil)
        }
      } else {
        let template = AMRQuestionAnswer()
        template.stylist = stylist
        template.qas = [[String:String]()]
        completion(template: template, error: nil)
      }
      
    }
  }
  
}

extension AMRQuestionAnswer: PFSubclassing {
  static func parseClassName() -> String {
    return "QuestionAnswer"
  }
  
}