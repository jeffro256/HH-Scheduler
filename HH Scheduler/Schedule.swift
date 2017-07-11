//
//  Schedule.swift
//  HH Scheduler
//
//  Created by Jeffrey Ryan on 7/11/17.
//  Copyright © 2017 Jeffrey Ryan. All rights reserved.
//

import Foundation

class Schedule: NSObject, NSCoding {
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

            //////////////////////////////////////////////////////////////////////////////////////////
            res_schedule.class_names = ["Free Time", "English", "Band", "Algebra II", "US History", "Chemistry", "Spanish Int A", "Biology", "Lecture"]
            res_schedule.classes =
                [[1, 1, 2, 2, 3, 3, 4, 4, 0, 0, 5, 5, 6, 6, 0, 0, 0, 0],
                 [6, 6, 0, 0, 7, 7, 5, 5, 5, 0, 4, 4, 0, 0, 2, 2, 1, 1],
                 [3, 3, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 7, 7, 7, 0, 6, 6],
                 [7, 7, 0, 8, 8, 8, 5, 5, 0, 0, 0, 0, 3, 3, 2, 2, 0, 0],
                 [3, 3, 2, 2, 1, 1, 4, 4, 0, 5, 5, 5, 6, 6, 0, 0, 7, 7],
                 [6, 6, 0, 7, 7, 7, 5, 5, 0, 0, 4, 4, 1, 1, 0, 0, 3, 3]]
            res_schedule.sport = "Cross Country"
            res_schedule.sport_end_time = Calendar.current.date(from: DateComponents(timeZone: TimeZone(abbreviation: "CST"), hour: 17, minute: 30))
            //////////////////////////////////////////////////////////////////////////////////////////
        }
        //////////////////////////////////////////////////////////////////////////////////////////////
        res_schedule.sport = nil
        //////////////////////////////////////////////////////////////////////////////////////////////

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
