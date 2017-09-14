//
//  UIColorExtension.swift
//  HH Scheduler
//
//  Created by Jeffrey Ryan on 9/12/17.
//  Copyright © 2017 Jeffrey Ryan. All rights reserved.
//

import UIKit

extension UIColor {
    convenience init(_ icolor: Int32) {
        self.init(red: CGFloat((icolor & 0x00FF0000) >> 16) / CGFloat(255), green: CGFloat((icolor & 0x0000FF00) >> 8) / CGFloat(255), blue: CGFloat(icolor & 0x000000FF) / CGFloat(255), alpha: 1.0)
    }
}
