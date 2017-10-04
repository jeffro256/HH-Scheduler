//
//  Common.swift
//  HH Scheduler
//
//  Created by Jeffrey Ryan on 9/5/16.
//  Copyright © 2016 Jeffrey Ryan. All rights reserved.
//

import UIKit

//duh
let NUM_DAYS = 6
let NUM_MODS = 18

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
    UIColor(0xFF3B30), // Red
    UIColor(0xFF9500), // Orange
    UIColor(0xFFCC00), // Yellow
    UIColor(0x4CD964), // Green
    UIColor(0x5AC8FA), // Light Blue
    UIColor(0x007AFF), // Blue
    UIColor(0x5856D6), // Purple
    UIColor(0xFF2D55), // Magenta
]
