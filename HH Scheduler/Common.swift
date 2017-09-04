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
    URL(string: "http://jeffaryan.com/schedule_keeper/hh_schedule_info.txt")!
let schedule_info_cache_file_name = "sinfo.cache.txt"
let schedule_info_cache_file_url: URL =
    document_dir_url.appendingPathComponent(schedule_info_cache_file_name)

enum ViewControllerIndexes: Int {
    case Dashboard = 0
    case Schedule
}

var schedule: Schedule!
var cycle_day = -1

// #C4161C
let hh_tint = UIColor(red: 196.0 / 255.0 , green: 22.0 / 255.0, blue: 28.0 / 255.0, alpha: 1.0)
// #EFEFF4
let freetime_color = UIColor(red: 0xEF / 255.0, green: 0xEF / 255.0, blue: 0xF4 / 255.0, alpha: 1.0)
