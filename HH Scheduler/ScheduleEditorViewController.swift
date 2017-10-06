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

        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? ClassEditorViewController, let editPath = self.editPath {
            vc.classID = newSchedule.getClassID(index: editPath.item)
            vc.shouldFocusText = self.editNewClass

            if !self.editNewClass, let classInfo = newSchedule.getClassInfo(withID: vc.classID) {
                vc.startName = classInfo.name
                vc.startColorIndex = color_pallette.index(of: classInfo.color)
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

    @IBAction func hitReorderButton(_ sender: Any) {
        guard let button = sender as? UIView else { print("Bad reorder sender!"); return }

        if tableView.isEditing {
            button.tintColor = UIColor(0xDDDDDD)
            tableView.isEditing = false
        }
        else {
            button.tintColor = hhTint
            tableView.isEditing = true
        }
    }

    @IBAction func hitAddButton(_ sender: Any) {
        if let selectedPath = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: selectedPath, animated: true)
        }

        newSchedule.addClass(withName: "New Class", color: color_pallette[0])

        let newIndex = IndexPath(row: tableView.numberOfRows(inSection: 0), section: 0)

        tableView.beginUpdates()
        tableView.insertRows(at: [newIndex], with: .automatic)
        tableView.endUpdates()

        tableView.selectRow(at: newIndex, animated: true, scrollPosition: .none)

        self.pullEditingScreen(at: newIndex, newClass: true)
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
        return newSchedule.getNumClasses()
    }

    // Create the cells
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let classInfoCell = tableView.dequeueReusableCell(withIdentifier: "ClassCell") as! ClassCell

        let classInfo = newSchedule.getClassInfo(withID: newSchedule.getClassID(index: indexPath.item))!
        classInfoCell.label.textColor = (indexPath.item == newSchedule.freetimeID()) ? UIColor.black : UIColor.white
        classInfoCell.label.text = classInfo.name
        classInfoCell.backgroundColor = classInfo.color

        return classInfoCell
    }

    // Will display cell
    var selectedFirst = false
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if !selectedFirst {
            tableView.selectRow(at: IndexPath(row: 0, section: 0), animated: true, scrollPosition: .none)
            selectedFirst = true
        }
    }

    // Selected cell
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedClassID = newSchedule.getClassID(index: indexPath.item)
    }

    // Whether cell should be editable
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
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

    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }

    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return .none
    }

    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let moveID = newSchedule.getClassID(index: sourceIndexPath.item)
        newSchedule.setClassIndex(withID: moveID, to: destinationIndexPath.item)
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return tableView.dequeueReusableCell(withIdentifier: "Header")
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }

    func deleteClass(_ indexPath: IndexPath) {
        let removeID = newSchedule.getClassID(index: indexPath.item)
        newSchedule.removeClass(withID: removeID)

        tableView.beginUpdates()
        tableView.deleteRows(at: [indexPath], with: .fade)
        tableView.endUpdates()
        scheduleCollectionView.reloadData()
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
}
