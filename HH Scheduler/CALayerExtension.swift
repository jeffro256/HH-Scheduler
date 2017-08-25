//
//  CALayerExtension.swift
//  HH Scheduler
//
//  Created by Jeffrey Ryan on 8/24/17.
//  Copyright © 2017 Jeffrey Ryan. All rights reserved.
//

import UIKit

extension CALayer {
    var shadowUIColor: UIColor? {
        get {
            guard let shadowColor = shadowColor else { return nil }
            return UIColor(cgColor: shadowColor)
        }
        set (newColor) {
            shadowColor = newColor?.cgColor
        }
    }

    var borderUIColor: UIColor? {
        get {
            guard let borderColor = borderColor else { return nil }
            return UIColor(cgColor: borderColor)
        }
        set (newColor) {
            borderColor = newColor?.cgColor
        }
    }
}
