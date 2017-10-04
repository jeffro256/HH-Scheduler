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

        scheduleCollectionView.setDataSource(scheduleSource: schedule)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        highlightCycleDay()
        gotoCurrentMod()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        scheduleCollectionView.collectionViewLayout.invalidateLayout()
    }

    public func highlightCycleDay() {
        let base_tag_num = 100
        let cycleDay = scheduleContext.getCycleDay(Date())
        for i in 0..<schedule.getNumDays() {
            if let day_label = cycleDayStack.viewWithTag(i + base_tag_num) as? UILabel {
                if i == cycleDay && cycleDay > 0 {
                    day_label.textColor = hhTint
                }
                else {
                    day_label.textColor = UIColor(white: 136.0 / 255.0, alpha: 1.0)
                }
            }
        }
    }

    public func gotoCurrentMod() {
        let now = Date()
        let nowTime = Calendar.current.date(from: Calendar.current.dateComponents([.hour, .minute, .second], from: now))!

        if let mod = scheduleContext.getBlocks(now, from: schedule).first(where: { b in nowTime >= b.startTime && nowTime < b.endTime })?.mod {
            let rows = schedule.getNumDays() + 1
            scheduleCollectionView.scrollToItem(at: IndexPath(row: mod * rows, section: 0), at: .centeredHorizontally, animated: true)
        }
    }

    @IBAction public func doneEditingSchedule(_ segue: UIStoryboardSegue) {
        if let vc = segue.source as? ScheduleEditorViewController {
            vc.save()
            scheduleCollectionView.setDataSource(scheduleSource: schedule)
            scheduleCollectionView.reloadData()
        }
    }
}


