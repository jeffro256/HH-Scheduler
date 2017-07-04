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
            let dayTag = i + 48
            if let cycleDayStack = scheduleTable.viewWithTag(dayTag) as? UIStackView {
                for j in 0 ..< 18 {
                    let modTag = j + 1
                    if let modView = cycleDayStack.viewWithTag(modTag) {
                        if modView is UILabel {
                            let modLabel = modView as! UILabel
                            modLabel.text = schedule.class_names[schedule.classes[i][j]]
                        }
                        else {
                            print("Cannot get label for cell (\(i), \(j))")
                        }
                    }
                    else {
                        print("Cannot find subview of stack \(i) for mod \(j)")
                    }
                }

                if let sportView = cycleDayStack.viewWithTag(19) {
                    if schedule.sport != nil {
                        if sportView is UILabel {
                            let sportLabel = sportView as! UILabel
                            sportLabel.text = schedule.sport
                            sportLabel.isHidden = false
                        }
                    }
                    else {
                        sportView.isHidden = true
                    }
                }
                else {
                    print("Cannot find sport view for stack \(i)")
                }
            }
            else {
                print("Cannot find subview of scheduleTable with tag \(dayTag)")
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
        }
    }

    func saveSchedule() {
        try! schedule.saveToFile(schedule_file_url)
    }

    func getSchedule() -> Schedule! {
        return schedule
    }
}
