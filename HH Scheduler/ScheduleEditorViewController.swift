//
//  ClassEditorViewController.swift
//  HH Scheduler
//
//  Created by Jeffrey Ryan on 7/10/17.
//  Copyright © 2017 Jeffrey Ryan. All rights reserved.
//

import UIKit

class ScheduleEditorViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var scheduleCollectionView: ScheduleEditorCollectionView!

    private var newSchedule: PSchedule!
    private var selectedClassID = 0

    private var editPath: IndexPath?
    private var editNewClass = false

    override func viewDidLoad() {
        super.viewDidLoad()

        newSchedule = schedule.copy() as! PSchedule
        scheduleCollectionView.scheduleController = self
        scheduleCollectionView.setDataSource(scheduleSource: newSchedule)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? ClassEditorViewController, let editPath = self.editPath {
            vc.classID = newSchedule.getClassID(index: editPath.item)

            if self.editNewClass {
                vc.startName = ""
                vc.startColor = nil
            }
            else {
                let classInfo = newSchedule.getClassInfo(withID: vc.classID)
                vc.startName = classInfo?.name
                vc.startColor = classInfo?.color
            }
        }
    }

    @IBAction public func doneEditingClass(_ segue: UIStoryboardSegue) {
        if let vc = segue.source as? ClassEditorViewController {
            let (name, color) = vc.getData()
            newSchedule.setClassName(withID: vc.classID, to: name)
            newSchedule.setClassColor(withID: vc.classID, to: color)
            tableView.reloadData()
            scheduleCollectionView.reloadData()
        }
    }

    @IBAction public func deleteClassSegue(_ segue: UIStoryboardSegue) {
        if let vc = segue.source as? ClassEditorViewController {
            deleteClass(IndexPath(row: newSchedule.getClassInfo(withID: vc.classID)!.classIndex, section: 0))
        }
    }

    public func save() {
        do {
            try newSchedule.saveToFile(schedule_file_url)
            print("Saved schedule file")
        }
        catch {
            print("Failed to save schedule file!")
        }

        schedule = newSchedule
    }

    // Get number of cells
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return newSchedule.getNumClasses() + 1
    }

    // Create the cells
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if isLastItem(indexPath) {
            let addCell = tableView.dequeueReusableCell(withIdentifier: "AddCell")!

            return addCell
        }
        else {
            let classInfoCell = tableView.dequeueReusableCell(withIdentifier: "ClassCell") as! ClassCell

            let classInfo = newSchedule.getClassInfo(withID: newSchedule.getClassID(index: indexPath.item))!
            classInfoCell.label.textColor = (indexPath.item == newSchedule.freetimeID()) ? UIColor.black : UIColor.white
            classInfoCell.label.text = classInfo.name
            classInfoCell.backgroundColor = classInfo.color
            classInfoCell.classID = classInfo.classID

            return classInfoCell
        }
    }

    // Will display cell
    var selectedFirst = false
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if isLastItem(indexPath) && !selectedFirst {
            tableView.selectRow(at: IndexPath(row: 0, section: 0), animated: true, scrollPosition: .none)
            selectedFirst = true
        }
    }

    // Selected cell
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if isLastItem(indexPath) {
            tableView.deselectRow(at: indexPath, animated: true)

            newSchedule.addClass(withName: "New Class", color: color_pallette[0])

            tableView.beginUpdates()
            tableView.insertRows(at: [indexPath], with: .automatic)
            tableView.endUpdates()

            tableView.selectRow(at: indexPath, animated: true, scrollPosition: .none)

            self.pullEditingScreen(at: indexPath, newClass: true)
        }

        selectedClassID = newSchedule.getClassID(index: indexPath.item)
    }

    // Whether cell should be editable
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return indexPath.item != 0 && !isLastItem(indexPath)
    }

    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let editAction = UITableViewRowAction(style: .destructive, title: "Edit") { action, index in
            self.pullEditingScreen(at: index, newClass: false)
        }
        editAction.backgroundColor = .lightGray

        return [editAction]
    }

    // Whether cell should be highlightable
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func deleteClass(_ indexPath: IndexPath) {
        let removeID = newSchedule.getClassID(index: indexPath.item)
        newSchedule.removeClass(withID: removeID)

        tableView.beginUpdates()
        tableView.deleteRows(at: [indexPath], with: .fade)
        tableView.endUpdates()
        scheduleCollectionView.reloadData()
    }

    private func isLastItem(_ indexPath: IndexPath) -> Bool {
        return indexPath.item == tableView.numberOfRows(inSection: 0) - 1
    }

    private func pullEditingScreen(at indexPath: IndexPath, newClass: Bool) {
        self.editPath = indexPath
        self.editNewClass = newClass
        self.performSegue(withIdentifier: "ClassEditSegue", sender: tableView.cellForRow(at: indexPath))
    }

    func getCurrentSelectedClassID() -> Int {
        return selectedClassID
    }
}

class ScheduleEditorCollectionView: ScheduleCollectionView {
    weak var scheduleController: ScheduleEditorViewController!

    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        let rows = scheduleSource.getNumDays() + 1
        return indexPath.item % rows != 0
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! ScheduleCell
        let selectedClassID = scheduleController.getCurrentSelectedClassID()
        let rows = scheduleSource.getNumDays() + 1
        let day = indexPath.item % rows - 1
        let mod = indexPath.item / rows
        let classInfo = scheduleSource.getClassInfo(atDay: day, mod: mod)

        if selectedClassID == classInfo.classID || selectedClassID == scheduleSource.freetimeID() {
            cell.label.text = nil
            cell.backgroundColor = scheduleSource.getClassInfo(withID: scheduleSource.freetimeID())?.color

            scheduleSource.setClassID(atDay: day, mod: mod, to: scheduleSource.freetimeID())
        }
        else {
            let selectedClassInfo = scheduleSource.getClassInfo(withID: selectedClassID)
            cell.label.text = selectedClassInfo?.name
            cell.backgroundColor = selectedClassInfo?.color

            scheduleSource.setClassID(atDay: day, mod: mod, to: selectedClassID)
        }
    }
}

class ClassCell: UITableViewCell {
    @IBOutlet weak var label: UILabel!
    var classID: Int!
}
