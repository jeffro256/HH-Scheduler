//
//  ScheduleManager.swift
//  HH Scheduler
//
//  Created by Jeffrey Ryan on 10/12/17.
//  Copyright © 2017 Jeffrey Ryan. All rights reserved.
//

import UIKit

class ScheduleManagerViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var tableLeading: NSLayoutConstraint!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var scheduleButton: UIBarButtonItem!
    @IBOutlet weak var scheduleCollection: ScheduleCollectionView!
    @IBOutlet weak var dayStack: UIStackView!
    private var viewingClasses = false

    public override func viewDidLoad() {
        super.viewDidLoad()

        scheduleCollection.scheduleManagerViewController = self
        scheduleCollection.scheduleSource = schedule

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

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if scheduleContext.isLoaded() {
            let cycleDay = scheduleContext.getCycleDay(Date())
            for day in 0..<schedule.getNumDays() {
                let tag = day + 1
                let view = dayStack.viewWithTag(tag) as! UILabel

                let greyColor = UIColor(0x888888)
                view.textColor = (day == cycleDay) ? hhTint : greyColor
            }
        }
    }

    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if scheduleContext.isLoaded(), let mod = scheduleContext.getMod(Date()) {
            let rows = schedule.getNumDays() + 1
            let modLabelIndexPath = IndexPath(row: rows * mod, section: 0)

            scheduleCollection.scrollToItem(at: modLabelIndexPath, at: .centeredHorizontally, animated: true)
        }
    }

    public override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)

        if segue.identifier == "toManageClasses" {
            let vc = segue.destination as! ClassManagerViewController
            vc.pschedule = schedule
        }
    }

    public func getSelectedClassID() -> PersonalSchedule.ClassID? {
        guard let sel_index = self.tableView.indexPathForSelectedRow?.item else { return nil }
        return schedule.getClassID(index: sel_index)
    }

    private var animating = false
    @IBAction func pressedScheduleIcon(_ sender: Any) {
        if (!animating) {
            let targetX = viewingClasses ? -tableView.frame.width : 0
            let buttonName = viewingClasses ? "Open Class Tab Icon" : "Close Class Tab Icon"

            scheduleButton.image = UIImage(named: buttonName)

            viewingClasses = !viewingClasses

            self.tableLeading.constant = targetX
            UIView.animate(withDuration: 0.25, animations: {
                self.view.layoutIfNeeded()
                self.animating = true

                if !self.viewingClasses, let selection = self.tableView.indexPathForSelectedRow {
                    self.tableView.deselectRow(at: selection, animated: true)
                }
            }, completion: { _ in
                self.animating = false
            })
        }
    }

    @IBAction func finishedManagingClasses(_ segue: UIStoryboardSegue) {
        self.tableView.reloadData()
        self.scheduleCollection.reloadData()
    }

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return schedule.getNumClasses()
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ClassInfoCell") as! ClassInfoCell

        let classInfo = schedule.getClassInfo(withID: schedule.getClassID(index: indexPath.item))
        cell.label.text = classInfo?.name
        cell.backgroundColor = classInfo?.color

        return cell
    }

    public func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return tableView.dequeueReusableCell(withIdentifier: "Floaty")?.contentView
    }

    public func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if tableView.indexPathForSelectedRow == indexPath {
            tableView.deselectRow(at: indexPath, animated: false)
            return nil
        }
        else {
            return indexPath
        }
    }
}

class ClassInfoCell: UITableViewCell {
    @IBOutlet public weak var label: UILabel!
}
