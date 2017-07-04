//
//  SecondViewController.swift
//  HH Scheduler
//
//  Created by Jeffrey Ryan on 9/3/16.
//  Copyright © 2016 Jeffrey Ryan. All rights reserved.
//

import UIKit

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

class ScheduleViewController: UIViewController {
    private var schedule: Schedule!

    @IBOutlet var scheduleTable: UIStackView!

    override func viewDidLoad() {
        super.viewDidLoad()

        addGradient(to: view)

        if schedule == nil {
            loadSchedule()
        }

        schedule.sport = "Cross Country"

        populateScheduleTable()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if let scrollView = view.viewWithTag(10) as? UIScrollView {
            let contentHeight = scrollView.frame.height
            let contentWidth = contentHeight * 4
            scrollView.contentSize = CGSize(width: contentWidth, height: contentHeight)
        }
    }

    func populateScheduleTable() {
        for i in 0 ..< 6 {
            let day_tag = i + 20
            if let cycle_day_stack = scheduleTable.viewWithTag(day_tag) {
                for j in 0 ..< 18 {
                    let mod_tag = j + 1
                    if let modLabel = cycle_day_stack.viewWithTag(mod_tag) as? UILabel {
                        modLabel.text = schedule.class_names[schedule.classes[i][j]]
                    }
                    else {
                        print("Cannot find subview of stack \(day_tag) for mod \(mod_tag)")
                    }
                }

                if let sport_label = cycle_day_stack.viewWithTag(19) as? UILabel {
                    sport_label.text = schedule.sport
                    sport_label.isHidden = schedule.sport == nil
                }
                else {
                    print("Could not get sport label for cycle day \(day_tag)")
                }
            }
            else {
                print("Cannot find subview of scheduleTable with tag \(day_tag)")
            }
        }
    }

    func loadSchedule() {
        if let schedule = Schedule.loadFromFile(schedule_file_url) {
            self.schedule = schedule
        }
        else {
            print("Creating new schedule...")
            self.schedule = Schedule()

            self.schedule.class_names = ["Free Time", "English", "Band", "Algebra II", "US History", "Chemistry", "Spanish Int A", "Biology", "Lecture"]
            self.schedule.classes =
                [[1, 1, 2, 2, 3, 3, 4, 4, 0, 0, 5, 5, 6, 6, 0, 0, 0, 0],
                 [6, 6, 0, 0, 7, 7, 5, 5, 5, 0, 4, 4, 0, 0, 2, 2, 1, 1],
                 [3, 3, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 7, 7, 7, 0, 6, 6],
                 [7, 7, 0, 8, 8, 8, 5, 5, 0, 0, 0, 0, 3, 3, 2, 2, 0, 0],
                 [3, 3, 2, 2, 1, 1, 4, 4, 0, 5, 5, 5, 6, 6, 0, 0, 7, 7],
                 [6, 6, 0, 7, 7, 7, 5, 5, 0, 0, 4, 4, 1, 1, 0, 0, 3, 3]]
            self.schedule.sport = "Cross Country"
            self.schedule.sport_end_time = Calendar.current.date(from: DateComponents(timeZone: TimeZone(abbreviation: "CST"), hour: 17, minute: 30))
        }
    }

    func saveSchedule() {
        try! schedule.saveToFile(schedule_file_url)
    }

    func getSchedule() -> Schedule! {
        return schedule
    }
}
