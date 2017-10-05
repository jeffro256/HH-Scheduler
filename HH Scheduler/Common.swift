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
    UIColor(0xFC635D),  // Red
    UIColor(0xFDA942),  // Orange
    UIColor(0xFED546),  // Yellow
    UIColor(0x74DF87),  // Green
    UIColor(0x7FD4F9),  // Light Blue
    UIColor(0x3A97FC),  // Blue
    UIColor(0x7A7BDB),  // Purple
    UIColor(0xFC5979),  // Magenta
]
