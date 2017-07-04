//
//  Paths.swift
//  HH Scheduler
//
//  Created by Jeffrey Ryan on 9/5/16.
//  Copyright © 2016 Jeffrey Ryan. All rights reserved.
//

import Foundation

let NUM_DAYS = 6
let NUM_CYCLES = 18

let document_dirs = NSSearchPathForDirectoriesInDomains(
    .documentDirectory,
    .userDomainMask, true)
let document_dir = document_dirs.first!
let document_dir_url = URL(fileURLWithPath: document_dir)

let schedule_file_name = "schedule.txt"
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
