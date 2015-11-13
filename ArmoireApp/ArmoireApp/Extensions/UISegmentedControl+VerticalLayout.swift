//
//  UISegmentedControl+VerticalLayout.swift
//  ArmoireApp
//
//  Created by Randy Ting on 11/10/15.
//  Copyright © 2015 Armoire. All rights reserved.
//

import UIKit

extension UISegmentedControl {
  func goVertical() {
    self.transform = CGAffineTransformMakeRotation(CGFloat(M_PI_2))
    for segment in self.subviews {
      for segmentSubview in segment.subviews {
        if segmentSubview is UILabel {
          (segmentSubview as! UILabel).transform = CGAffineTransformMakeRotation(CGFloat(-M_PI_2))
        }
      }
    }
  }
  func restoreHorizontal() {
    self.transform = CGAffineTransformIdentity
    for segment in self.subviews {
      for segmentSubview in segment.subviews {
        if segmentSubview is UILabel {
          (segmentSubview as! UILabel).transform = CGAffineTransformIdentity
        }
      }
    }
  }
}
