//
//  ScheduleViewController.swift
//  HH Scheduler
//
//  Created by Jeffrey Ryan on 9/3/16.
//  Copyright © 2016 Jeffrey Ryan. All rights reserved.
//

import UIKit

class ScheduleViewController: UIViewController {
     override func viewDidLoad() {
        super.viewDidLoad()

        addGradient(to: self.view)

        if schedule == nil {
            schedule = Schedule.defaultLoadFromFile(schedule_file_url)
        }
    }
}

class ClassCell: UICollectionViewCell {
    @IBOutlet weak var label: UILabel!
}
