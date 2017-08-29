//
//  ScheduleDataSource.swift
//  HH Scheduler
//
//  Created by Jeffrey Ryan on 8/25/17.
//  Copyright © 2017 Jeffrey Ryan. All rights reserved.
//

import UIKit

protocol ScheduleDataSource {
    func getDays() -> Int
    func getMods() -> Int
    func getNumberClasses() -> Int
    func getClassName(index: Int) -> String
    func setClassName(index: Int, name: String)
    func addClass(name: String)
    func removeClass(index: Int)
    //func getClassColor(index: Int) -> UIColor
    //func setClassColor(index: Int, color: UIColor)
    func getClassIndex(day: Int, mod: Int) -> Int
    func setClassIndex(day: Int, mod: Int, index: Int)
    func getSportName() -> String?
    func setSportName(name: String?)
    func getSportEndTime() -> Date?
    func setSportEndTime(time: Date?)
    //func getSportColor() -> UIColor
    //func setSportColor(color: UIColor)
}
