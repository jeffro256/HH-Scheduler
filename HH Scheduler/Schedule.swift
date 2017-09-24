//
//  Schedule.swift
//  HH Scheduler
//
//  Created by Jeffrey Ryan on 7/11/17.
//  Copyright © 2017 Jeffrey Ryan. All rights reserved.
//

import UIKit

class Schedule: NSObject, NSCoding, NSCopying, ScheduleDataSource {
    var class_names: [String]
    var classes: [[Int]]                // 6 x 18

    override var description: String {
        return "class_names: \(class_names)\nclasses: \(classes)"
    }

    override init() {
        class_names = ["Free Time"]
        classes = [[Int]](repeating: [Int](repeating: 0, count: NUM_MODS), count: NUM_DAYS)

        super.init()
    }

    init(class_names: [String], classes: [[Int]], sport: String? = nil, sport_end_time: Date? = nil) {
        self.class_names = class_names
        self.classes = classes

        super.init()
    }

    func copy(with zone: NSZone? = nil) -> Any {
        let copy = Schedule(class_names: class_names, classes: classes)
        return copy
    }

    static func loadFromFile(_ target: URL) -> Schedule? {
        return NSKeyedUnarchiver.unarchiveObject(withFile: target.path) as? Schedule
    }

    static func defaultLoadFromFile(_ target: URL) -> Schedule {
        var res_schedule: Schedule

        if let file_schedule = Schedule.loadFromFile(schedule_file_url) {
            res_schedule = file_schedule
        }
        else {
            print("Creating new schedule...")
            res_schedule = Schedule()
        }

        return res_schedule
    }

    func saveToFile(_ target: URL) throws {
        if !NSKeyedArchiver.archiveRootObject(self, toFile: target.path) {
            throw NSError(domain: "Failed to save schedule to file", code: 2, userInfo: nil)
        }
    }

    required init(coder aDecoder: NSCoder) {
        class_names = aDecoder.decodeObject(forKey: "class_names") as! [String]
        classes = aDecoder.decodeObject(forKey: "classes") as! [[Int]]

        super.init()
    }

    func encode(with aCoder: NSCoder) {
        aCoder.encode(class_names, forKey: "class_names")
        aCoder.encode(classes, forKey: "classes")
    }

    // ScheduleDataSource Interface

    func getDays() -> Int {
        return NUM_DAYS
    }

    func getMods() -> Int {
        return NUM_MODS
    }

    func getNumberClasses() -> Int {
        return class_names.count
    }

    func getClassName(index: Int) -> String {
        return class_names[index]
    }

    func setClassName(index: Int, name: String) {
        class_names[index] = name
    }

    func addClass(name: String) {
        class_names.append(name)
    }

    func getClassColor(classID: Int) -> UIColor {
        return (classID == 0) ? freetime_color : color_pallette[(classID - 1) % color_pallette.count]
    }

    func removeClass(index: Int) {
        for d in 0..<classes.count {
            for m in 0..<classes[0].count {
                if classes[d][m] == index {
                    classes[d][m] = 0
                }
                else if classes[d][m] > index {
                    classes[d][m] -= 1
                }
            }
        }

        class_names.remove(at: index)
    }

    func getClassIndex(day: Int, mod: Int) -> Int {
        return classes[day][mod]
    }

    func setClassIndex(day: Int, mod: Int, index: Int) {
        classes[day][mod] = index
    }

    func getBlock(day: Int, mod: Int) -> ScheduleBlock {
        let classIndex = getClassIndex(day: day, mod: mod)
        let className = getClassName(index: classIndex)
        let classColor = getClassColor(classID: classIndex)
        return ScheduleBlock(name: className, classID: classIndex, color: classColor)
    }
}
