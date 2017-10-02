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

    private var newSchedule: Schedule!
    private var selectedClassIndex = 0

    private var editPath: IndexPath?

    override func viewDidLoad() {
        super.viewDidLoad()

        newSchedule = schedule.copy() as! Schedule
        scheduleCollectionView.scheduleController = self
        scheduleCollectionView.setDataSource(scheduleSource: newSchedule)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? ClassEditorViewController, let editPath = self.editPath {
            vc.classIndex = editPath.item
        }
    }

    @IBAction public func doneEditingClass(_ segue: UIStoryboardSegue) {
        if let vc = segue.source as? ClassEditorViewController {
            let (name, _) = vc.getData()
            newSchedule.setClassName(index: vc.classIndex, name: name)
            //newSchedule.setClassColor(index: classIndex, color: color)
            tableView.reloadData()
            scheduleCollectionView.reloadData()
        }
    }

    @IBAction public func deleteClassSegue(_ segue: UIStoryboardSegue) {
        if let vc = segue.source as? ClassEditorViewController {
            deleteClass(IndexPath(row: vc.classIndex, section: 0))
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
        return newSchedule.getNumberClasses() + 1
    }

    // Create the cells
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if isLastItem(indexPath) {
            let add_cell = tableView.dequeueReusableCell(withIdentifier: "AddCell")!

            return add_cell
        }
        else {
            let class_info_cell = tableView.dequeueReusableCell(withIdentifier: "ClassCell") as! ClassCell

            class_info_cell.label.text = newSchedule.getClassName(index: indexPath.item)
            class_info_cell.backgroundColor = newSchedule.getClassColor(classID: indexPath.item)

            return class_info_cell
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

            newSchedule.addClass(name: "New Class")

            tableView.beginUpdates()
            tableView.insertRows(at: [indexPath], with: .automatic)
            tableView.endUpdates()

            tableView.selectRow(at: indexPath, animated: true, scrollPosition: .none)
        }

        selectedClassIndex = indexPath.item
    }

    // Whether cell should be editable
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return indexPath.item != 0 && !isLastItem(indexPath)
    }

    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let editAction = UITableViewRowAction(style: .destructive, title: "Edit") { action, index in
            self.editPath = index
            self.performSegue(withIdentifier: "EditClassSegue", sender: nil)
        }
        editAction.backgroundColor = .lightGray

        return [editAction]
    }

    // Whether cell should be highlightable
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func editClass(at indexPath: IndexPath) {
        print("editing: \(indexPath.item)")
    }

    func deleteClass(_ indexPath: IndexPath) {
        newSchedule.removeClass(index: indexPath.item)

        tableView.beginUpdates()
        tableView.deleteRows(at: [indexPath], with: .fade)
        tableView.endUpdates()
        scheduleCollectionView.reloadData()
    }

    private func isLastItem(_ indexPath: IndexPath) -> Bool {
        return indexPath.item == tableView.numberOfRows(inSection: 0) - 1
    }

    func getCurrentSelectedClass() -> Int {
        return selectedClassIndex
    }
}

class ScheduleEditorCollectionView: ScheduleCollectionView {
    weak var scheduleController: ScheduleEditorViewController!

    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        let rows = scheduleSource.getDays() + 1
        return indexPath.item % rows != 0
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! ScheduleCell
        let selected_class = scheduleController.getCurrentSelectedClass()
        let rows = scheduleSource.getDays() + 1
        let day = indexPath.item % rows - 1
        let mod = indexPath.item / rows
        let block = scheduleSource.getBlock(day: day, mod: mod)

        if selected_class == block.classID || selected_class == 0 {
            cell.label.text = nil
            cell.backgroundColor = freetime_color

            scheduleSource.setClassIndex(day: day, mod: mod, index: 0)
        }
        else {
            cell.label.text = scheduleSource.getClassName(index: selected_class)
            cell.backgroundColor = scheduleSource.getClassColor(classID: selected_class)

            scheduleSource.setClassIndex(day: day, mod: mod, index: selected_class)
        }
    }
}

class ClassCell: UITableViewCell {
    @IBOutlet weak var label: UILabel!
}
