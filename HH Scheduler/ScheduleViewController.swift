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
    @IBOutlet weak var cycleDayStack: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        highlightCycleDay()

        scheduleCollectionView.setDataSource(scheduleSource: schedule)
        scheduleCollectionView.reloadData()
    }

    public func highlightCycleDay() {
        let base_tag_num = 100
        let cycleDay = cschedule.getCycleDay(Date())
        guard cycleDay >= 0 else { return }
        for i in 0..<NUM_DAYS {
            if let day_label = cycleDayStack.viewWithTag(i + base_tag_num) as? UILabel {
                if i == cycleDay {
                    day_label.textColor = hh_tint
                }
                else {
                    day_label.textColor = UIColor(white: 136.0 / 255.0, alpha: 1.0)
                }
            }
        }
    }
}


