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
    func getClassIndex(day: Int, mod: Int) -> Int
    func setClassIndex(day: Int, mod: Int, index: Int)
    func getBlock(day: Int, mod: Int) -> ScheduleBlock
}

class ScheduleBlock {
    public var name: String
    public var classID: Int
    public var color: UIColor?

    public init(name: String, classID: Int, color: UIColor?) {
        self.name = name
        self.classID = classID
        self.color = color
    }
}

class ContextScheduleBlock: ScheduleBlock {
    public var startTime: Date
    public var endTime: Date
    public var schedule: ContextSchedule
    public var mod: Int?

    public init(name: String, classID: Int,  color: UIColor?, startTime: Date, endTime: Date, from schedule: ContextSchedule, mod: Int? = nil) {
        self.schedule = schedule
        self.startTime = startTime
        self.endTime = endTime
        self.mod = mod

        super.init(name: name, classID: classID, color: color)
    }
}
