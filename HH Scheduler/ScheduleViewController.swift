//
//  SecondViewController.swift
//  HH Scheduler
//
//  Created by Jeffrey Ryan on 9/3/16.
//  Copyright © 2016 Jeffrey Ryan. All rights reserved.
//

import UIKit

class Schedule: NSObject, NSCoding {
    var classes: [String]
    var schedule: [[Int]]
    var sport: String?
    var sport_times: [Date]?

    override init() {
        classes = ["Free Time"]
        schedule = [[Int]](repeating: [Int](repeating: 0, count: 18), count: 6)
        sport = nil
        sport_times = nil

        super.init()
    }

    static func loadFromFile(_ target: URL) -> Schedule? {
        return NSKeyedUnarchiver.unarchiveObject(withFile: target.path) as? Schedule
    }

    func saveToFile(_ target: URL) throws {
        if !NSKeyedArchiver.archiveRootObject(self, toFile: target.path) {
            throw NSError(domain: "Failed to save schedule to file", code: 2, userInfo: nil)
        }
    }

    required init(coder aDecoder: NSCoder) {
        classes = aDecoder.decodeObject(forKey: "classes") as! [String]
        schedule = aDecoder.decodeObject(forKey: "schedule") as! [[Int]]
        sport = aDecoder.decodeObject(forKey: "sport") as! String?
        sport_times = aDecoder.decodeObject(forKey: "sport_times") as! [Date]?

        super.init()
    }

    func encode(with aCoder: NSCoder) {
        aCoder.encode(classes, forKey: "classes")
        aCoder.encode(schedule, forKey: "schedule")
        aCoder.encode(sport, forKey: "sport")
        aCoder.encode(sport_times, forKey: "sport_times")
    }
}

class ScheduleViewController: UIViewController {
    static var schedule: Schedule?

    override func viewDidLoad() {
        super.viewDidLoad()

        addGradient(to: view)

        if ScheduleViewController.schedule == nil {
            ScheduleViewController.loadSchedule()
        }

        try! ScheduleViewController.schedule?.saveToFile(schedule_file_url)
    }

    override func viewDidAppear(_ animated: Bool) {
        if let scrollView = view.viewWithTag(10) as? UIScrollView {
            scrollView.contentSize = CGSize(width: scrollView.frame.height * 1.5, height: scrollView.frame.height)
        }
    }

    static func loadSchedule() {
        if let schedule = Schedule.loadFromFile(schedule_file_url) {
            ScheduleViewController.schedule = schedule
        }
        else {
            print("Creating new schedule...")
            ScheduleViewController.schedule = Schedule()
        }
    }
}
