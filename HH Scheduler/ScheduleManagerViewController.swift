//
//  ScheduleManager.swift
//  HH Scheduler
//
//  Created by Jeffrey Ryan on 10/12/17.
//  Copyright © 2017 Jeffrey Ryan. All rights reserved.
//

import UIKit

class ScheduleManagerViewController: UIViewController {
    @IBOutlet weak var tableLeading: NSLayoutConstraint!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var scheduleButton: UIBarButtonItem!

    private var viewingClasses = false

    public override func viewDidLoad() {
        super.viewDidLoad()

        tableLeading.constant = -tableView.frame.width
    }

    private var firstLayout = true
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        if firstLayout {
            tableLeading.constant = -tableView.frame.width
            firstLayout = false
        }
    }

    @IBAction func pressedScheduleIcon(_ sender: Any) {
        let targetX = viewingClasses ? -tableView.frame.width : 0
        let buttonName = viewingClasses ? "Open Class Tab Icon" : "Close Class Tab Icon"

        scheduleButton.image = UIImage(named: buttonName)

        viewingClasses = !viewingClasses

        self.tableLeading.constant = targetX
        UIView.animate(withDuration: 0.25) {
            self.view.layoutIfNeeded()
        }
    }

    @IBAction func finishedManagingClasses(_ segue: UIStoryboardSegue) {
        
    }
}
