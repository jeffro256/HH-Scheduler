//
//  Common.swift
//  HH Scheduler
//
//  Created by Jeffrey Ryan on 9/5/16.
//  Copyright © 2016 Jeffrey Ryan. All rights reserved.
//

import UIKit

// Variables ///////////////////////////////////////////////////////////////////

var schedule: PSchedule!
var scheduleContext: ScheduleContext!
var isFirstStartup = false

// Constants ///////////////////////////////////////////////////////////////////

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

let doc_dir_url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
let cache_dir_url = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
let app_support_dir_url = try! FileManager.default.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)

let schedule_file_name = "schedule.arc"
let schedule_file_url: URL =
    doc_dir_url.appendingPathComponent(schedule_file_name)

let context_cache_file_name = "context_cahce.json"
let context_cache_file_url: URL =
    cache_dir_url.appendingPathComponent(context_cache_file_name)

let first_startup_flag_name = "first_start.txt"
let first_startup_flag_url: URL = app_support_dir_url.appendingPathComponent(first_startup_flag_name)

let schedule_info_web_url = URL(string: "http://jeffaryan.com/schedule_keeper/hh_schedule_info.json")!
