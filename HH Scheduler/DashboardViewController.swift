//
//  DashboardViewController.swift
//  HH Scheduler
//
//  Created by Jeffrey Ryan on 9/3/16.
//  Copyright © 2016 Jeffrey Ryan. All rights reserved.
//

/*
 99 little bugs in the code
 99 little bugs,
 Take one down
 Pass it around...
 127 little bugs in the code.
 */

import UIKit

class DashboardViewController: UIViewController {
    @IBOutlet var Circle1: UIView!
    @IBOutlet var Circle2: UIView!
    @IBOutlet var CycleDayLabel: UILabel!
    @IBOutlet var ModLabel: UILabel!
    @IBOutlet var ExtraLabel: UILabel!
    @IBOutlet var ClassLabel1: UILabel!
    @IBOutlet var ClassLabel2: UILabel!
    @IBOutlet var ClassTimeLabel1: UILabel!
    @IBOutlet var ClassTimeLabel2: UILabel!
    @IBOutlet var CurrentClassLabel: UILabel!
    @IBOutlet var NextClassLabel: UILabel!

    private var scheduleController: ScheduleViewController!

    private static let timeInputter: DateFormatter = {
        let a = DateFormatter()
        a.dateFormat = "hh:mmaa"
        a.locale = Locale(identifier: "en_US")          // Do I really know what I'm doing here? no.
        a.timeZone = TimeZone(abbreviation: "CST")

        return a
    }()
    private static let dateInputter: DateFormatter = {
        let a = DateFormatter()
        a.dateFormat = "dd MMMM yyyy"
        a.locale = Locale(identifier: "en_US")          // Do I really know what I'm doing here? ditto.
        a.timeZone = TimeZone(abbreviation: "CST")

        return a
    }()

    private static let timeOutputter: DateFormatter = {
        let a = DateFormatter()
        a.dateFormat = "hh:mmaa"

        return a
    }()
    private static let dateOutputter: DateFormatter = {
        let a = DateFormatter()
        a.dateFormat = "dd MMMM yyyy"

        return a
    }()

    private var reg_mod_times: [Date]!
    private var late_mod_times: [Date]!
    private var reg_start_time: Date!,
                reg_end_time: Date!,
                late_start_time: Date!,
                late_end_time: Date!
    private var recorded_cycle_days: [(Date, Int)]!
    private var holidays: [Date]!
    private var weird_days: [(Date, [Date]?)]!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        addGradient(to: self.view)
        
        scheduleController = (tabBarController?.viewControllers?[ViewControllerIndexes.Schedule.rawValue] as? UINavigationController)?.viewControllers.first as? ScheduleViewController

        if scheduleController.getSchedule() == nil {
            scheduleController.loadSchedule()
        }

        refreshScheduleInfo()
        updateUI()

        // @Remove
        /*
        let t2s = {(d: Date) in return DashboardViewController.timeFormatter.string(from: d)}
        let d2s = {(d: Date) in return DashboardViewController.dateFormatter.string(from: d)}
        print("reg_mod_times", reg_mod_times.map(t2s))
        print("late_mod_times", late_mod_times.map(t2s))
        print("reg_start_time", t2s(reg_start_time))
        print("reg_end_time", t2s(reg_end_time))
        print("late_start_time", t2s(late_start_time))
        print("late_end_time", t2s(late_end_time))
        print("recorded_cycle_days", recorded_cycle_days.map({(d, c) in return (d2s(d), c)}))
        print("holidays", holidays.map(d2s))
        print("weird_days", weird_days)
        */
    }

    override func viewDidLayoutSubviews() {
        Circle1.layer.cornerRadius = Circle1.frame.width / 2
        Circle2.layer.cornerRadius = Circle2.frame.width / 2
    }

    func updateUI() {
        // set mod
        // set cycle day
        // set current class
        // set next class
        // get times of those classes
        // OR
        // set extra text label

        /*

         If schedule-less weird day, holiday, or weekend, make all normal spaces
         blank, and set the extra text label.

         Otherwise::

         For day since last recorded day, if not weekend, holiday, or weird day
         without schedule, increment the cycle day counter. Mod the cycle day
         counter. This is the cycle day

         If it is a weird day, use that schedule. If it is wednesday, use late
         schedule. Otherwise use regular schedule. Get mod from that schedule.
         
         Index the mod into the schedule and get class and next class.
         
         Get times of those classes.

        */

        let now = Date()
        let is_holiday = holidays.contains(where: { now.dayCompare($0) == .orderedSame })
        let is_weekend = Calendar.current.isDateInWeekend(now)
        var weird_day_times: [Date]?
        let is_weird_day = weird_days.contains(where: { if now.dayCompare($0.0) == .orderedSame { weird_day_times = $0.1; return true } else { return false } })

        if is_holiday || is_weekend {
            ModLabel.isHidden = true
            CycleDayLabel.isHidden = true
            ClassLabel1.isHidden = true
            ClassLabel2.isHidden = true
            ClassTimeLabel1.isHidden = true
            ClassTimeLabel2.isHidden = true
            CurrentClassLabel.isHidden = true
            NextClassLabel.isHidden = true
            ExtraLabel.isHidden = false
            ExtraLabel.text = "No School Today!"
        }
        else if is_weird_day && weird_day_times == nil {
            ModLabel.isHidden = true
            CycleDayLabel.isHidden = true
            ClassLabel1.isHidden = true
            ClassLabel2.isHidden = true
            ClassTimeLabel1.isHidden = true
            ClassTimeLabel2.isHidden = true
            CurrentClassLabel.isHidden = true
            NextClassLabel.isHidden = true
            ExtraLabel.isHidden = false
            ExtraLabel.text = "Weird Schedule Today"
        }
        else {
            // Get Cycle Day

            var lastRecordedCycleDay = recorded_cycle_days[0]

            for rcd in recorded_cycle_days {
                if rcd.0.dayCompare(now) != .orderedDescending {
                    lastRecordedCycleDay = rcd
                }
                else {
                    break
                }
            }

            let one_day = DateComponents(day: 1)
            while lastRecordedCycleDay.0.dayCompare(now) == .orderedAscending {
                let next_day = Calendar.current.date(byAdding: one_day, to: lastRecordedCycleDay.0)!
                let next_day_is_holiday = holidays.contains(where: { next_day.dayCompare($0) == .orderedSame })
                let next_day_is_weekend = Calendar.current.isDateInWeekend(next_day)
                let next_day_is_scheduleless_weird_day = weird_days.contains(where: { next_day.dayCompare($0.0) == .orderedSame })

                if !next_day_is_holiday && !next_day_is_weekend && !next_day_is_scheduleless_weird_day {
                    lastRecordedCycleDay.1 += 1
                }

                lastRecordedCycleDay.0 = next_day
            }

            let cycle_day = lastRecordedCycleDay.1 % 6

            let mod_times: [Date]
            if is_weird_day {
                mod_times = weird_day_times!
            }
            else {
                if cycle_day == 3 {
                    mod_times = late_mod_times
                }
                else {
                    mod_times = reg_mod_times
                }
            }

            let dateless_now_components = Calendar.current.dateComponents([.hour, .minute], from: now)
            let nowTime = Calendar.current.date(from: dateless_now_components)!

            if Calendar.current.compare(nowTime, to: mod_times.first!, toGranularity: .minute) == .orderedAscending {   // before school
                ModLabel.isHidden = true
                CycleDayLabel.isHidden = true
                ClassLabel1.isHidden = true
                ClassLabel2.isHidden = false
                ClassTimeLabel1.isHidden = true
                ClassTimeLabel2.isHidden = false
                CurrentClassLabel.isHidden = true
                NextClassLabel.isHidden = false
                ExtraLabel.isHidden = false
                ClassLabel2.text = "School Starts"
                ClassTimeLabel2.text = DashboardViewController.timeOutputter.string(from: mod_times[0])
                ExtraLabel.text = "Good Morning!"
            }
            else if (scheduleController.getSchedule().sport != nil && Calendar.current.compare(nowTime, to: scheduleController.getSchedule().sport_end_time!, toGranularity: .minute) != .orderedAscending) || (scheduleController.getSchedule().sport == nil && Calendar.current.compare(nowTime, to: mod_times.last!, toGranularity: .minute) != .orderedAscending) {     // after school
                ModLabel.isHidden = true
                CycleDayLabel.isHidden = true
                ClassLabel1.isHidden = true
                ClassLabel2.isHidden = true
                ClassTimeLabel1.isHidden = true
                ClassTimeLabel2.isHidden = true
                CurrentClassLabel.isHidden = true
                NextClassLabel.isHidden = true
                ExtraLabel.isHidden = false
                ExtraLabel.text = "School is Over!"
            }
            else if scheduleController.getSchedule().sport != nil && Calendar.current.compare(nowTime, to: mod_times.last!, toGranularity: .minute) != .orderedAscending && Calendar.current.compare(nowTime, to: scheduleController.getSchedule().sport_end_time!, toGranularity: .minute) == .orderedAscending { // in sports
                // @TODO: Put in-sports code
            }
            else {  // during school
                var mod: Int
                for m in (0...mod_times.count).reversed() {
                    if Calendar.current.compare(nowTime, to: mod_times[m], toGranularity: .minute) != .orderedAscending {
                        mod = m
                        break
                    }
                }
            }
        }
    }

    func refreshScheduleInfo() {
        reg_mod_times = []
        late_mod_times = []
        recorded_cycle_days = []
        holidays = []
        weird_days = []

        var schedule_info_contents = try? String(contentsOf: schedule_info_web_url).strip()

        if schedule_info_contents == nil {
            print("Cannot find info file on web, falling back onto cached file")
            schedule_info_contents = try! String(contentsOf: schedule_info_cache_file_url)
        }

        try? schedule_info_contents!.write(to: schedule_info_cache_file_url, atomically: true, encoding: .utf8)

        let schedule_info_list = schedule_info_contents!.components(separatedBy: CharacterSet.newlines)

        // @TODO<START>: Make code in block more error robust
        let reg_mod_time_strs = schedule_info_list[0].components(separatedBy: ",")

        for mod_time_str in reg_mod_time_strs {
            let mod_time_raw = DashboardViewController.timeInputter.date(from: mod_time_str.strip())!
            let dateless_mod_time_components = Calendar.current.dateComponents([.hour, .minute], from: mod_time_raw)
            let mod_time = Calendar.current.date(from: dateless_mod_time_components)!
            self.reg_mod_times.append(mod_time)
        }

        let late_mod_time_strs = schedule_info_list[1].components(separatedBy: ",")

        for mod_time_str in late_mod_time_strs {
            let mod_time_raw = DashboardViewController.timeInputter.date(from: mod_time_str.strip())!
            let dateless_mod_time_components = Calendar.current.dateComponents([.hour, .minute], from: mod_time_raw)
            let mod_time = Calendar.current.date(from: dateless_mod_time_components)!
            self.reg_mod_times.append(mod_time)
        }

        // @TODO: optimize next 4 lines: save components
        self.reg_start_time = DashboardViewController.timeInputter.date(from: schedule_info_list[2].components(separatedBy: ",")[0].strip())
        self.reg_end_time = DashboardViewController.timeInputter.date(from: schedule_info_list[2].components(separatedBy: ",")[1].strip())
        self.late_start_time = DashboardViewController.timeInputter.date(from: schedule_info_list[3].components(separatedBy: ",")[0].strip())
        self.late_end_time = DashboardViewController.timeInputter.date(from: schedule_info_list[3].components(separatedBy: ",")[1].strip())

        var line_index = 4
        var line = schedule_info_list[line_index]

        while !line.contains("Holidays:") {
            // @TODO: optimize next 2 lines: save components
            let calendar_day = DashboardViewController.dateInputter.date(from: line.components(separatedBy: ",")[0].strip())
            let cycle_day = Int(line.components(separatedBy: ",")[1].strip().unicodeScalars.first!.value) - 65 // 65 is value of A
            self.recorded_cycle_days.append((calendar_day!, cycle_day))

            line_index += 1
            line = schedule_info_list[line_index]
        }

        line_index += 1
        line = schedule_info_list[line_index]

        recorded_cycle_days.sort { $0.0.dayCompare($1.0) == .orderedAscending }

        while !line.contains("Weird Days:") {
            let holiday = DashboardViewController.dateInputter.date(from: line.strip())
            self.holidays.append(holiday!)

            line_index += 1
            line = schedule_info_list[line_index]
        }

        holidays.sort()

        while line_index < schedule_info_list.count - 1 {
            line_index += 1
            line = schedule_info_list[line_index]

            let lineComponents = line.components(separatedBy: ",")
            if let weird_day = DashboardViewController.dateInputter.date(from: lineComponents[0].strip()) {
                if (lineComponents.count == 1) {
                    self.weird_days.append((weird_day, nil))
                }
                else {
                    let mod_time_strs = lineComponents[1..<lineComponents.count]
                    var weird_mod_times = [Date]()

                    for mod_time_str in mod_time_strs {
                        weird_mod_times.append(DashboardViewController.dateInputter.date(from: mod_time_str.strip())!)
                    }

                    self.weird_days.append((weird_day, weird_mod_times))
                }
            }
            else {
                print("ERROR: weird day invalid '\(lineComponents[0].strip())'")
            }
        }

        weird_days.sort { $0.0.dayCompare($1.0) == .orderedAscending }
        // @TODO<END>
    }

    // NOTE: Some of this code is useless, as this view controller will always
    // be on the far right
    @IBAction func handleSwipes(_ sender: AnyObject) {
        let tabIndex = tabBarController!.selectedIndex

        if (sender.direction == .right && tabIndex > 0) {
            tabBarController!.selectedIndex -= 1
        }

        if (sender.direction == .left && tabIndex < tabBarController!.viewControllers!.count - 1) {
            tabBarController!.selectedIndex += 1
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
