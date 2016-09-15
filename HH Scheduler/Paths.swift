//
//  Paths.swift
//  HH Scheduler
//
//  Created by Jeffrey Ryan on 9/5/16.
//  Copyright © 2016 Jeffrey Ryan. All rights reserved.
//

import Foundation

let document_dirs = NSSearchPathForDirectoriesInDomains(
    .DocumentDirectory,
    .UserDomainMask, true)
let document_dir = document_dirs.first!
let document_dir_url = NSURL(fileURLWithPath: document_dir)

let schedule_file_name = "schedule.txt"
let schedule_file_url =
    document_dir_url.URLByAppendingPathComponent(schedule_file_name)

let schedule_info_web_url =
    NSURL(string: "http://jeffaryan.com/schedule_keeper/hh_schedule_info.txt")!
let schedule_info_cache_file_name = "sinfo.cache.txt"
let schedule_info_cache_file_url =
    document_dir_url.URLByAppendingPathComponent(schedule_info_cache_file_name)