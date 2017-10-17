//
//  Common.swift
//  HH Scheduler
//
//  Created by Jeffrey Ryan on 9/5/16.
//  Copyright © 2016 Jeffrey Ryan. All rights reserved.
//

import UIKit

let document_dirs = NSSearchPathForDirectoriesInDomains(
    .documentDirectory,
    .userDomainMask, true)
let document_dir = document_dirs.first!
let document_dir_url = URL(fileURLWithPath: document_dir)

let schedule_file_name = "schedule.arc"
let schedule_file_url: URL =
    document_dir_url.appendingPathComponent(schedule_file_name)

let schedule_info_web_url =
    URL(string: "http://jeffaryan.com/schedule_keeper/hh_schedule_info.json")!
let schedule_info_backup_file_name = "sinfo_cache.json"
let schedule_info_backup_file_url: URL =
    document_dir_url.appendingPathComponent(schedule_info_backup_file_name)

var schedule: PSchedule!
var scheduleContext: ScheduleContext!

let hhTint = UIColor(0xC4161C)
let freetimeColor = UIColor(0xEFEFF4)

let color_pallette = [
    UIColor(0xFF6259),  // Red
    UIColor(0xFFAA33),  // Orange
    UIColor(0xFFD633),  // Yellow
    UIColor(0x70E183),  // Green
    UIColor(0x7BD3FB),  // Light Blue
    UIColor(0x3395FF),  // Blue
    UIColor(0x7978DE),  // Purple
    UIColor(0xFF5777),  // Magenta
]
