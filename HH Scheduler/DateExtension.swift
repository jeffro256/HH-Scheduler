//
//  DateExtension.swift
//  HH Scheduler
//
//  Created by Jeffrey Ryan on 12/15/16.
//  Copyright © 2016 Jeffrey Ryan. All rights reserved.
//

import Foundation

extension Date {
    func dayCompare(_ a: Date) -> ComparisonResult {
        return Calendar.current.compare(self, to: a, toGranularity: .day)
    }
}
