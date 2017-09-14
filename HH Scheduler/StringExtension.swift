//
//  StringExtension.swift
//  HH Scheduler
//
//  Created by Jeffrey Ryan on 10/5/16.
//  Copyright © 2016 Jeffrey Ryan. All rights reserved.
//

import UIKit

extension String {
    public func strip() -> String {
        return self.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    }

    public func split(sep: String = " ") -> [String] {
        return self.components(separatedBy: sep)
    }

    public func scalarRandomColor() -> UIColor {
        var scalar_sum = 0

        for s in self.unicodeScalars {
            scalar_sum += Int(s.value)
        }

        srand48(scalar_sum)

        let r = CGFloat(drand48()); let g = CGFloat(drand48()); let b = CGFloat(drand48())

        return UIColor(red: r, green: g, blue: b, alpha: 1.0)
    }
}
