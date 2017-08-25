//
//  Schedule.swift
//  HH Scheduler
//
//  Created by Jeffrey Ryan on 7/11/17.
//  Copyright © 2017 Jeffrey Ryan. All rights reserved.
//

import Foundation

class Schedule: NSObject, NSCoding, NSCopying {
    var class_names: [String]
    var classes: [[Int]]                // 6 x 18
    var sport: String?
    var sport_end_time: Date?

    override var description: String {
        return "class_names: \(class_names)\nclasses: \(classes)\nsport: \(String(describing: sport))\nsport_end_time: \(String(describing: sport_end_time))"
    }

    override init() {
        class_names = ["Free Time"]
        classes = [[Int]](repeating: [Int](repeating: 0, count: 18), count: 6)
        sport = nil
        sport_end_time = nil

        super.init()
    }

    init(class_names: [String], classes: [[Int]], sport: String? = nil, sport_end_time: Date? = nil) {
        self.class_names = class_names
        self.classes = classes
        self.sport = sport
        self.sport_end_time = sport_end_time

        super.init()
    }

    func copy(with zone: NSZone? = nil) -> Any {
        let copy = Schedule(class_names: class_names, classes: classes, sport: sport, sport_end_time: sport_end_time)
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
        sport = aDecoder.decodeObject(forKey: "sport") as! String?
        sport_end_time = aDecoder.decodeObject(forKey: "sport_end_time") as! Date?

        super.init()
    }

    func encode(with aCoder: NSCoder) {
        aCoder.encode(class_names, forKey: "class_names")
        aCoder.encode(classes, forKey: "classes")
        aCoder.encode(sport, forKey: "sport")
        aCoder.encode(sport_end_time, forKey: "sport_end_time")
    }
}
