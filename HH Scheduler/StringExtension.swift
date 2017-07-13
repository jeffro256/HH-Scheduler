//
//  StringExtension.swift
//  HH Scheduler
//
//  Created by Jeffrey Ryan on 10/5/16.
//  Copyright © 2016 Jeffrey Ryan. All rights reserved.
//

import Foundation
import CoreGraphics

extension String {
    public func strip() -> String {
        return self.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    }

    public func scalarRand(num_rands: Int) -> [CGFloat] {
        var scalar_sum = 0

        for s in self.unicodeScalars {
            scalar_sum += Int(s.value)
        }

        srand48(scalar_sum)

        var results: [CGFloat] = []

        for _ in 0..<num_rands {
            results.append(CGFloat(drand48()))
        }

        return results
    }
}
