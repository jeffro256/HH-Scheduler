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
}

class ScheduleBlock {
    public var name: String
    public var color: UIColor?

    public init(name: String, color: UIColor?) {
        self.name = name
        self.color = color
    }
}

class ContextScheduleBlock: ScheduleBlock {
    public var schedule: ContextSchedule
    public var blockID: Int
    public var isNormal: Bool

    public init(name: String, color: UIColor?, from schedule: ContextSchedule, withID blockID: Int, normal isNormal: Bool) {
        self.schedule = schedule
        self.blockID = blockID
        self.isNormal = isNormal

        super.init(name: name, color: color)
    }
}
