//
//  ScheduleDataSource.swift
//  HH Scheduler
//
//  Created by Jeffrey Ryan on 8/25/17.
//  Copyright © 2017 Jeffrey Ryan. All rights reserved.
//

import UIKit

protocol PersonalSchedule {
    typealias ClassID = Int
    func getNumDays() -> Int
    func getNumMods() -> Int
    func getNumClasses() -> Int
    func getClassID(index: Int) -> ClassID
    func getClassInfo(withID: ClassID) -> ScheduleClass?
    func setClassName(withID: ClassID, to: String)
    func setClassColor(withID: ClassID, to: UIColor)
    func setClassIndex(withID: ClassID, to: Int)
    @discardableResult
    func addClass(withName: String, color: UIColor) -> ClassID
    func removeClass(withID: ClassID)
    func getClassID(atDay: Int, mod: Int) -> ClassID
    func setClassID(atDay: Int, mod: Int, to: ClassID)
    func getClassInfo(atDay: Int, mod: Int) -> ScheduleClass
    func freetimeID() -> PersonalSchedule.ClassID
}

struct ScheduleClass {
    public var classID: PersonalSchedule.ClassID
    public var classIndex: Int
    public var name: String
    public var color: UIColor
}
