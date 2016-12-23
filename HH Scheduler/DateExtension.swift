//
//  DateExtension.swift
//  HH Scheduler
//
//  Created by Jeffrey Ryan on 12/15/16.
//  Copyright © 2016 Jeffrey Ryan. All rights reserved.
//

import Foundation

extension Date {
    var timeIntervalSinceDayStart: TimeInterval {
        let com = Calendar.current.dateComponents([.year, .month, .day], from: self)
        let dayStart = Calendar.current.date(from: com)

        return (self.timeIntervalSinceReferenceDate - dayStart!.timeIntervalSinceReferenceDate)
    }

    func dcompare(_ a: Date) -> ComparisonResult {
        return Calendar.current.compare(self, to: a, toGranularity: .day)
    }
}
