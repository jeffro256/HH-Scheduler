//
//  FirstViewController.swift
//  HH Scheduler
//
//  Created by Jeffrey Ryan on 9/3/16.
//  Copyright © 2016 Jeffrey Ryan. All rights reserved.
//

import UIKit

class DashboardViewController: UIViewController {
    @IBOutlet var Circle1: UIView!
    @IBOutlet var Circle2: UIView!
    @IBOutlet var ClassLabel1: UILabel!
    @IBOutlet var ClassLabel2: UILabel!

    private var scheduleController: ScheduleViewController!
    private static let timeFormatter: DateFormatter = {
        let a = DateFormatter()
        a.dateFormat = "hh:mmaa"
        a.locale = Locale(identifier: "en_US")
        a.timeZone = TimeZone(abbreviation: "GMT+0:00")

        return a
    }()
    private static let dateFormatter: DateFormatter = {
        let a = DateFormatter()
        a.dateFormat = "dd MMMM yyyy"
        a.locale = Locale(identifier: "en_US")
        a.timeZone = TimeZone(abbreviation: "GMT+0:00")

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

        if scheduleController.schedule == nil {
            scheduleController.loadSchedule()
        }

        print(DashboardViewController.dateFormatter.date(from: "12 May 2001"))
    }

    override func viewDidLayoutSubviews() {
        Circle1.layer.cornerRadius = Circle1.frame.width / 2
        Circle2.layer.cornerRadius = Circle2.frame.width / 2
    }

    func refreshScheduleInfo() {
        var schedule_info_contents = try? String(contentsOf: schedule_info_web_url)

        if schedule_info_contents == nil {
            schedule_info_contents = try! String(contentsOf: schedule_info_cache_file_url)
        }

        try? schedule_info_contents!.write(to: schedule_info_cache_file_url, atomically: true, encoding: .utf8)

        let schedule_info_list = schedule_info_contents!.components(separatedBy: CharacterSet.newlines)

        // @TODO: Make code in do block more error robust
        do {
            let reg_mod_time_strs = schedule_info_list[0].components(separatedBy: ",")

            for mod_time_str in reg_mod_time_strs {
                self.reg_mod_times.append(DashboardViewController.timeFormatter.date(from: mod_time_str.strip())!)
            }

            let late_mod_time_strs = schedule_info_list[1].components(separatedBy: ",")

            for mod_time_str in late_mod_time_strs {
                self.late_mod_times.append(DashboardViewController.timeFormatter.date(from: mod_time_str.strip())!)
            }

            // @TODO: optimize next 4 lines: save components
            self.reg_start_time = DashboardViewController.timeFormatter.date(from: schedule_info_list[2].components(separatedBy: ",")[0].strip())
            self.reg_end_time = DashboardViewController.timeFormatter.date(from: schedule_info_list[2].components(separatedBy: ",")[1].strip())
            self.late_start_time = DashboardViewController.timeFormatter.date(from: schedule_info_list[3].components(separatedBy: ",")[0].strip())
            self.late_end_time = DashboardViewController.timeFormatter.date(from: schedule_info_list[3].components(separatedBy: ",")[1].strip())

            var line_index = 4
            var line = schedule_info_list[line_index]

            while !line.contains("Holidays:") {
                // @TODO: optimize next 2 lines: save components
                let calendar_day = DashboardViewController.dateFormatter.date(from: line.components(separatedBy: ",")[0].strip())
                let cycle_day = Int(line.components(separatedBy: ",")[1].strip().unicodeScalars.first!.value)
                self.recorded_cycle_days.append((calendar_day!, cycle_day))

                line_index += 1
                line = schedule_info_list[line_index]
            }

            line_index += 1
            line = schedule_info_list[line_index]

            while !line.contains("Weird Days:") {
                let holiday = DashboardViewController.dateFormatter.date(from: line.strip())
                self.holidays.append(holiday!)

                line_index += 1
                line = schedule_info_list[line_index]
            }

            line_index += 1
            line = schedule_info_list[line_index]

            while line_index < schedule_info_list.count {
                let lineComponents = line.components(separatedBy: ",")
                let weird_day = DashboardViewController.dateFormatter.date(from: lineComponents[0].strip())

                if (lineComponents.count == 1) {
                    self.weird_days.append((weird_day!, nil))
                }
                else {
                    let mod_time_strs = lineComponents[1..<lineComponents.count]
                    var weird_mod_times = [Date]()

                    for mod_time_str in mod_time_strs {
                        weird_mod_times.append(DashboardViewController.dateFormatter.date(from: mod_time_str.strip())!)
                    }

                    self.weird_days.append((weird_day!, weird_mod_times))
                }
            }
        }
        catch {
            print("Error while parsing HH Schedule Info")
        }
    }

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

