//
//  UIColorExtension.swift
//  HH Scheduler
//
//  Created by Jeffrey Ryan on 9/12/17.
//  Copyright © 2017 Jeffrey Ryan. All rights reserved.
//

import UIKit

extension UIColor {
    convenience init(_ icolor: Int32, _ alpha: CGFloat = 1.0) {
        self.init(red: CGFloat((icolor & 0x00FF0000) >> 16) / CGFloat(255), green: CGFloat((icolor & 0x0000FF00) >> 8) / CGFloat(255), blue: CGFloat(icolor & 0x000000FF) / CGFloat(255), alpha: alpha)
    }

    func asInt32() -> Int32 {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0

        self.getRed(&red, green: &green, blue: &blue, alpha: nil)

        return Int32(red * 255) << 16 | Int32(green * 255) << 8 | Int32(blue * 255)
    }
}
