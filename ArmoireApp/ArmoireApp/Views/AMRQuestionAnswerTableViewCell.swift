//
//  AMRQuestionAnswerTableViewCell.swift
//  ArmoireApp
//
//  Created by Mathew Kellogg on 11/8/15.
//  Copyright © 2015 Armoire. All rights reserved.
//

import UIKit

class AMRQuestionAnswerTableViewCell: AMRDynamicHeightTableViewCell {
  
  
  class func cellReuseIdentifier() -> String{
    return "com.armoire.AMRQuestionAnswerTableViewCell"
  }

  @IBOutlet weak var question: UILabel!
  @IBOutlet weak var answer: UITextView!
  
  override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
    question.sizeToFit()
    answer.sizeToFit()
  }
  
  override func setSelected(selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    
    // Configure the view for the selected state
  }
 
  override func getCellHeight(width: CGFloat?) -> CGFloat {
    let heightMargins = CGFloat(24) //TODO calculate this better.
    let widthMargins = CGFloat(32)
    
    // quesiton
    var questionFixedWidth: CGFloat
    if let suggestedWidth = width {
      questionFixedWidth = suggestedWidth - widthMargins
    } else {
      questionFixedWidth = question.frame.size.width
    }
    let questionNewSize : CGSize = question.sizeThatFits(CGSizeMake(questionFixedWidth, CGFloat(MAXFLOAT)))
    var questionNewFrame : CGRect = question.frame
    questionNewFrame.size = CGSizeMake(CGFloat(fmaxf((Float)(questionNewSize.width), (Float)(questionFixedWidth))),questionNewSize.height)
    
    // answer
    var answerFixedWidth: CGFloat
    if let suggestedWidth = width {
      answerFixedWidth = suggestedWidth - widthMargins
    } else {
      answerFixedWidth = answer.frame.size.width
    }
    let answerNewSize : CGSize = answer.sizeThatFits(CGSizeMake(answerFixedWidth, CGFloat(MAXFLOAT)))
    var answerNewFrame : CGRect = answer.frame
    answerNewFrame.size = CGSizeMake(CGFloat(fmaxf((Float)(answerNewSize.width), (Float)(answerFixedWidth))),answerNewSize.height)
    
    
    return questionNewFrame.height + answerNewFrame.height + heightMargins
  }
}
