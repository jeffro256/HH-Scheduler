//
//  ScheduleViewController.swift
//  HH Scheduler
//
//  Created by Jeffrey Ryan on 9/3/16.
//  Copyright © 2016 Jeffrey Ryan. All rights reserved.
//

import UIKit

class ScheduleViewController: UIViewController {
    @IBOutlet weak var scheduleCollectionView: ScheduleCollectionView!

     override func viewDidLoad() {
        super.viewDidLoad()

        if schedule == nil {
            schedule = Schedule.defaultLoadFromFile(schedule_file_url)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)


        scheduleCollectionView.setDataSource(scheduleSource: schedule)
        scheduleCollectionView.reloadData()
    }
}


