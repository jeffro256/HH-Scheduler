//
//  DashboardViewController.swift
//  HH Scheduler
//
//  Created by Jeffrey Ryan on 9/3/16.
//  Copyright © 2016 Jeffrey Ryan. All rights reserved.
//

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

    private let time_formatter: DateFormatter = {
        let a = DateFormatter()
        a.dateFormat = "hh:mmaa"
        a.locale = Locale(identifier: "en_US")
        a.timeZone = TimeZone(abbreviation: "CST")

        return a
    }()
    private let date_formatter: DateFormatter = {
        let a = DateFormatter()
        a.dateFormat = "dd MMMM yyyy"
        a.locale = Locale(identifier: "en_US")
        a.timeZone = TimeZone(abbreviation: "CST")

        return a
    }()
    private let friendly_time_fmtr: DateFormatter = {
        let a = DateFormatter()
        a.dateFormat = "h:mm aa"
        a.locale = Locale(identifier: "en_US")
        a.timeZone = TimeZone(abbreviation: "CST")

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
    private var weird_days: [(Date, [Date]?, Date?, Date?)]!

    override func viewDidLoad() {
        super.viewDidLoad()

        addGradient(to: self.view)
        
        if schedule == nil {
            schedule = Schedule.defaultLoadFromFile(schedule_file_url)
        }

        refreshScheduleInfo()

        updateUI()
    }

    override func viewDidLayoutSubviews() {
        Circle1.layer.cornerRadius = Circle1.frame.width / 2
        Circle2.layer.cornerRadius = Circle2.frame.width / 2
    }

    func updateUI() {
        let now = Date()
        let is_holiday = holidays.contains(where: { now.dayCompare($0) == .orderedSame })
        let is_weekend = Calendar.current.isDateInWeekend(now)
        var weird_mod_times: [Date]?
        var weird_start_time: Date?
        var weird_end_time: Date?
        let is_weird_day = weird_days.contains(where: { if now.dayCompare($0.0) == .orderedSame { weird_mod_times = $0.1; weird_start_time = $0.2; weird_end_time = $0.3; return true } else { return false } })

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
        else if is_weird_day && weird_mod_times == nil {
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

            var lastRecordedCycleDay = recorded_cycle_days.first!

            for rcd in recorded_cycle_days.reversed() {
                if rcd.0.dayCompare(now) != .orderedDescending {
                    lastRecordedCycleDay = rcd
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

            let is_late_day = cycle_day == 3 || Calendar.current.component(.weekday, from: now) == 4

            let mod_times: [Date]
            let start_time: Date
            let end_time: Date

            if is_weird_day && weird_mod_times != nil {
                mod_times = weird_mod_times!
            }
            else if is_late_day {
                mod_times = late_mod_times
            }
            else {
                mod_times = reg_mod_times
            }

            if is_weird_day && weird_start_time != nil {
                start_time = weird_start_time!
            }
            else if is_late_day {
                start_time = late_start_time
            }
            else {
                start_time = reg_start_time
            }

            if is_weird_day && weird_end_time != nil {
                end_time = weird_end_time!
            }
            else if is_late_day {
                end_time = late_end_time
            }
            else {
                end_time = reg_end_time
            }

            let dateless_now_components = Calendar.current.dateComponents([.hour, .minute], from: now)
            let nowTime = Calendar.current.date(from: dateless_now_components)!

            if Calendar.current.compare(nowTime, to: start_time, toGranularity: .minute) == .orderedAscending {   // before school
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
                ClassTimeLabel2.text = friendly_time_fmtr.string(from: start_time)
                ExtraLabel.text = "Good Morning!"
            }
            else if Calendar.current.compare(nowTime, to: mod_times.first!, toGranularity: .minute) == .orderedAscending {
                //@todo WHAT ABOUT WEIRD DAYS UGGGH
                ModLabel.isHidden = true
                CycleDayLabel.isHidden = true
                ClassLabel1.isHidden = false
                ClassLabel1.text = "Morning Meeting"
                ClassLabel2.isHidden = false
                ClassLabel2.text = schedule.class_names[schedule.classes[cycle_day][0]]
                ClassTimeLabel1.isHidden = false
                ClassTimeLabel1.text = friendly_time_fmtr.string(from: start_time)
                ClassTimeLabel2.isHidden = false
                ClassTimeLabel2.text = friendly_time_fmtr.string(from: mod_times.first!)
                CurrentClassLabel.isHidden = false
                NextClassLabel.isHidden = false
                ExtraLabel.isHidden = false
                ExtraLabel.text = "Good Morning!"
            }
            else if (schedule.sport != nil && Calendar.current.compare(nowTime, to: schedule.sport_end_time!, toGranularity: .minute) != .orderedAscending) || (schedule.sport == nil && Calendar.current.compare(nowTime, to: end_time, toGranularity: .minute) != .orderedAscending) {     // after school
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
            else if schedule.sport != nil && Calendar.current.compare(nowTime, to: end_time, toGranularity: .minute) != .orderedAscending && Calendar.current.compare(nowTime, to: schedule.sport_end_time!, toGranularity: .minute) == .orderedAscending { // in sports
                ModLabel.isHidden = true
                CycleDayLabel.isHidden = true
                ClassLabel1.isHidden = false
                ClassLabel1.text = schedule.sport
                ClassLabel2.isHidden = false
                ClassLabel2.text = schedule.sport! + " Ends"
                ClassTimeLabel1.isHidden = false
                ClassTimeLabel1.text = friendly_time_fmtr.string(from: end_time)
                ClassTimeLabel2.isHidden = false
                ClassTimeLabel2.text = friendly_time_fmtr.string(from: schedule.sport_end_time!)
                CurrentClassLabel.isHidden = false
                NextClassLabel.isHidden = false
                ExtraLabel.isHidden = true
            }
            else {  // during school
                var current_mod = -1
                for mod in (0..<mod_times.count).reversed() {
                    if Calendar.current.compare(nowTime, to: mod_times[mod], toGranularity: .minute) != .orderedAscending {
                        current_mod = mod
                        break
                    }
                }

                if current_mod < 0 {
                    print("Could not get mod number! Exiting...")
                    exit(EXIT_FAILURE)
                }

                let current_class = schedule.classes[cycle_day][current_mod]
                let current_class_name = schedule.class_names[current_class]

                var current_class_start_mod = current_mod - 1
                while (current_class_start_mod >= 0) {
                    if (schedule.classes[cycle_day][current_class_start_mod] != current_class) {
                        current_class_start_mod += 1
                        break
                    }

                    current_class_start_mod -= 1
                }

                if (current_class_start_mod < 0) {
                    current_class_start_mod = 0
                }

                let current_class_time = mod_times[current_class_start_mod]

                var next_class_mod = current_mod + 1
                while next_class_mod < mod_times.count {
                    let nxt_clss_indx = schedule.classes[cycle_day][next_class_mod]

                    if (nxt_clss_indx != current_class) {
                        break
                    }

                    next_class_mod += 1
                }

                let next_class_name: String
                let next_class_time: Date
                if (next_class_mod >= mod_times.count) { // No next class
                    next_class_name = (schedule.sport == nil) ? "School Ends" : schedule.sport!
                    next_class_time = end_time
                }
                else {
                    next_class_name = schedule.class_names[schedule.classes[cycle_day][next_class_mod]]
                    next_class_time = mod_times[next_class_mod]
                }

                let cycle_character = Character(UnicodeScalar(Int(("A" as UnicodeScalar).value) + cycle_day)!)

                ModLabel.isHidden = false
                ModLabel.text = "Mod \(current_mod+1)"
                CycleDayLabel.isHidden = false
                CycleDayLabel.text = "\(cycle_character) Day"
                ClassLabel1.isHidden = false
                ClassLabel1.text = current_class_name
                ClassLabel2.isHidden = false
                ClassLabel2.text = next_class_name
                ClassTimeLabel1.isHidden = false
                ClassTimeLabel1.text = friendly_time_fmtr.string(from: current_class_time)
                ClassTimeLabel2.isHidden = false
                ClassTimeLabel2.text = friendly_time_fmtr.string(from: next_class_time)
                CurrentClassLabel.isHidden = false
                NextClassLabel.isHidden = false
                ExtraLabel.isHidden = true
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
        let reg_mod_time_strs = schedule_info_list[0].components(separatedBy: " ")

        for mod_time_str in reg_mod_time_strs {
            let mod_time_raw = time_formatter.date(from: mod_time_str.strip())!
            let dateless_mod_time_components = Calendar.current.dateComponents([.hour, .minute], from: mod_time_raw)
            let mod_time = Calendar.current.date(from: dateless_mod_time_components)!
            self.reg_mod_times.append(mod_time)
        }

        let late_mod_time_strs = schedule_info_list[1].components(separatedBy: " ")

        for mod_time_str in late_mod_time_strs {
            let mod_time_raw = time_formatter.date(from: mod_time_str.strip())!
            let dateless_mod_time_components = Calendar.current.dateComponents([.hour, .minute], from: mod_time_raw)
            let mod_time = Calendar.current.date(from: dateless_mod_time_components)!
            self.late_mod_times.append(mod_time)
        }

        self.reg_start_time = time_formatter.date(from: schedule_info_list[2].components(separatedBy: " ")[0].strip())
        self.reg_end_time = time_formatter.date(from: schedule_info_list[2].components(separatedBy: " ")[1].strip())
        self.late_start_time = time_formatter.date(from: schedule_info_list[3].components(separatedBy: " ")[0].strip())
        self.late_end_time = time_formatter.date(from: schedule_info_list[3].components(separatedBy: " ")[1].strip())

        let reg_start_time_comp = Calendar.current.dateComponents([.hour, .minute], from: reg_start_time)
        let reg_end_time_comp = Calendar.current.dateComponents([.hour, .minute], from: reg_end_time)
        let late_start_time_comp = Calendar.current.dateComponents([.hour, .minute], from: late_start_time)
        let late_end_time_comp = Calendar.current.dateComponents([.hour, .minute], from: late_end_time)

        self.reg_start_time = Calendar.current.date(from: reg_start_time_comp)
        self.reg_end_time = Calendar.current.date(from: reg_end_time_comp)
        self.late_start_time = Calendar.current.date(from: late_start_time_comp)
        self.late_end_time = Calendar.current.date(from: late_end_time_comp)

        var line_index = 4
        var line = schedule_info_list[line_index]

        while !line.contains("Holidays:") {
            // @TODO: optimize next 2 lines: save components
            let calendar_day = date_formatter.date(from: line.components(separatedBy: ",")[0].strip())
            let cycle_day = Int(line.components(separatedBy: ",")[1].strip().unicodeScalars.first!.value) - 65 // 65 is value of A
            self.recorded_cycle_days.append((calendar_day!, cycle_day))

            line_index += 1
            line = schedule_info_list[line_index]
        }

        line_index += 1
        line = schedule_info_list[line_index]

        recorded_cycle_days.sort { $0.0 < $1.0 }

        while !line.contains("Weird Days:") {
            let holiday = date_formatter.date(from: line.strip())
            self.holidays.append(holiday!)

            line_index += 1
            line = schedule_info_list[line_index]
        }

        holidays.sort()

        while line_index < schedule_info_list.count - 1 {
            line_index += 1
            line = schedule_info_list[line_index]

            let lineComponents = line.components(separatedBy: ",")
            if let weird_day = date_formatter.date(from: lineComponents[0].strip()) {
                var weird_mod_times: [Date]?
                var weird_start_time: Date?
                var weird_end_time: Date?

                if (lineComponents.count >= 2) {
                    let weird_start_time_raw = time_formatter.date(from: lineComponents[1].strip().components(separatedBy: " ")[0])!
                    let weird_end_time_raw = time_formatter.date(from: lineComponents[1].strip().components(separatedBy: " ")[1])!
                    let weird_start_comps = Calendar.current.dateComponents([.hour, .minute], from: weird_start_time_raw)
                    let weird_end_comps = Calendar.current.dateComponents([.hour, .minute], from: weird_end_time_raw)
                    weird_start_time = Calendar.current.date(from: weird_start_comps)
                    weird_end_time = Calendar.current.date(from: weird_end_comps)
                }

                if (lineComponents.count >= 3) {
                    weird_mod_times = []

                    let weird_mod_time_strs = lineComponents[2].components(separatedBy: " ")

                    for wmts in weird_mod_time_strs {
                        let weird_mod_time_raw = time_formatter.date(from: wmts)!
                        let weird_mod_comps = Calendar.current.dateComponents([.hour, .minute], from: weird_mod_time_raw)
                        let weird_mod_time = Calendar.current.date(from: weird_mod_comps)
                        weird_mod_times?.append(weird_mod_time!)
                    }
                }

                self.weird_days.append((weird_day, weird_mod_times, weird_start_time, weird_end_time))
            }
            else {
                print("ERROR: weird day invalid '\(lineComponents[0].strip())'")
            }
        }

        weird_days.sort { $0.0 < $1.0 }

        // @TODO<END>
    }

    // NOTE: Some of this code is useless, as this view controller will always
    // be on the far right. In fact, it even listens to Alex Jones unironically.
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
