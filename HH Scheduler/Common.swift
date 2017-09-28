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
let schedule_info_cache_file_name = "sinfo_cache.json"
let schedule_info_cache_file_url: URL =
    document_dir_url.appendingPathComponent(schedule_info_cache_file_name)

var schedule: Schedule!
var cschedule: ContextSchedule!

// #C4161C
let hh_tint = UIColor(red: 196.0 / 255.0 , green: 22.0 / 255.0, blue: 28.0 / 255.0, alpha: 1.0)
// #EFEFF4
let freetime_color = UIColor(red: 0xEF / 255.0, green: 0xEF / 255.0, blue: 0xF4 / 255.0, alpha: 1.0)

let color_pallette = [
/*
Red -        #FF3B30
Orange -     #FF9500
Yellow -     #FFCC00
Green -      #4CD964
Light Blue - #5AC8FA
Blue -       #007AFF
Purple -     #5856D6
Magenta -    #FF2D55
*/

    UIColor(0xFF3B30),
    UIColor(0xFF9500),
    UIColor(0xFFCC00),
    UIColor(0x4CD964),
    UIColor(0x5AC8FA),
    UIColor(0x007AFF),
    UIColor(0x5856D6),
    UIColor(0xFF2D55),
]
