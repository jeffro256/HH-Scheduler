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

    override func viewDidLoad() {
        super.viewDidLoad()
        
        addGradient(to: self.view)

        var schedule_info_contents = try? String(contentsOf: schedule_info_web_url)

        _ = try? schedule_info_contents?.write(to: schedule_info_cache_file_url, atomically: true, encoding: String.Encoding.utf8)

        if schedule_info_contents == nil {
            print("Using cache file: Couldn't get schedule info from web")
            schedule_info_contents = try? String(contentsOf: schedule_info_cache_file_url)
        }

        if schedule_info_contents == nil {
            print("ERROR: Couldn't get schedule_info_contents")
            exit(EXIT_FAILURE)
        }
        
        scheduleController = (tabBarController?.viewControllers?[ViewControllerIndexes.Schedule.rawValue] as? UINavigationController)?.viewControllers.first as? ScheduleViewController

        if scheduleController.schedule == nil {
            scheduleController.loadSchedule()
        }
    }

    override func viewDidLayoutSubviews() {
        Circle1.layer.cornerRadius = Circle1.frame.width / 2
        Circle2.layer.cornerRadius = Circle2.frame.width / 2
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

