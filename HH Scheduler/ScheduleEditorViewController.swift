//
//  ClassEditorViewController.swift
//  HH Scheduler
//
//  Created by Jeffrey Ryan on 7/10/17.
//  Copyright © 2017 Jeffrey Ryan. All rights reserved.
//


import UIKit

class ScheduleEditorViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var scheduleCollectionView: ScheduleEditorCollectionView!

    private var newSchedule: Schedule!

    var selectedClassIndex = 0

    func isLastItem(_ indexPath: IndexPath) -> Bool {
        return indexPath.item == tableView.numberOfRows(inSection: 0) - 1
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        scheduleCollectionView.scheduleController = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        newSchedule = schedule.copy() as! Schedule
        scheduleCollectionView.setDataSource(scheduleSource: newSchedule)
        scheduleCollectionView.reloadData()
    }

    @IBAction func pressedSaveButton(_ sender: Any) {
        save()
    }

    private func save() {
        try! newSchedule.saveToFile(schedule_file_url)
        schedule = newSchedule

        navigationController?.popToViewController((navigationController?.viewControllers.first)!, animated: true)
    }

    // Get number of cells
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return newSchedule.getNumberClasses() + 1
    }

    // Create the cells
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.item == 0 {
            let free_time_cell = tableView.dequeueReusableCell(withIdentifier: "FreeTimeCell")!

            return free_time_cell
        }
        else if isLastItem(indexPath) {
            let add_cell = tableView.dequeueReusableCell(withIdentifier: "AddCell")

            return add_cell!
        }
        else {
            let class_info_cell = tableView.dequeueReusableCell(withIdentifier: "ClassInfoCell") as! ClassInfoCell

            class_info_cell.field.text = newSchedule.class_names[indexPath.item]
            class_info_cell.field.isEnabled = false
            class_info_cell.field.tag = indexPath.item
            class_info_cell.colorize()

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
            selectedClassIndex = indexPath.item
        }
        else {
            if indexPath.item != 0 {
                let cell = tableView.cellForRow(at: indexPath) as! ClassInfoCell
                cell.field.isEnabled = true
            }

            selectedClassIndex = indexPath.item
        }
    }

    // Deselected cell
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if !isLastItem(indexPath) && indexPath.item != 0 {
            let cell = tableView.cellForRow(at: indexPath) as! ClassInfoCell
            cell.field.isEnabled = false
        }
    }

    // Whether cell should be editable
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return indexPath.item != 0 && !isLastItem(indexPath)
    }

    // Delete cell
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            deleteClass(indexPath)
        }
    }

    // Whether cell should be highlightable
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    // I don't know, it works
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true) // beware, magic!

        return false
    }

    // Done typing
    func textFieldDidEndEditing(_ textField: UITextField) {
        if (textField.text?.isEmpty)! {
            let indexPath = IndexPath(row: textField.tag, section: 0)
            deleteClass(indexPath)
        }
        else {
            newSchedule.setClassName(index: textField.tag, name: textField.text!)
            scheduleCollectionView.reloadData()
        }
    }

    // Limits width of class names
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else { return true }
        let newText = (text as NSString).replacingCharacters(in: range, with: string)
        let attribs = [NSFontAttributeName: textField.font!]
        let newWidth = newText.size(attributes: attribs).width
        return newWidth <= tableView.frame.width - 10
    }

    func deleteClass(_ indexPath: IndexPath) {
        newSchedule.removeClass(index: indexPath.item)

        tableView.beginUpdates()
        tableView.deleteRows(at: [indexPath], with: .fade)
        tableView.endUpdates()
        scheduleCollectionView.reloadData()
    }

    func getCurrentSelectedClass() -> Int {
        return selectedClassIndex
    }
}

class ScheduleEditorCollectionView: ScheduleCollectionView {
    var scheduleController: ScheduleEditorViewController!

    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        let rows = NUM_DAYS + 1
        return indexPath.item % rows != 0 && indexPath.item < rows * NUM_MODS
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! ScheduleCell
        let selected_class = scheduleController.getCurrentSelectedClass()
        let rows = NUM_DAYS + 1
        let day = (indexPath.item - indexPath.item / rows - 1) % NUM_DAYS
        let mod = (indexPath.item - indexPath.item / rows - 1) / NUM_DAYS

        if selected_class == scheduleSource.getClassIndex(day: day, mod: mod) || selected_class == 0 {
            cell.label.text = nil
            cell.backgroundColor = freetime_color

            scheduleSource.setClassIndex(day: day, mod: mod, index: 0)
        }
        else {
            cell.label.text = scheduleSource.getClassName(index: selected_class)
            cell.backgroundColor = color_pallette[selected_class % color_pallette.count]

            scheduleSource.setClassIndex(day: day, mod: mod, index: selected_class)
        }
    }
}

class ClassInfoCell: UITableViewCell {
    @IBOutlet weak var field: UITextField!

    @IBAction func hitEnter(_ sender: Any) {
        colorize()
    }

    public func colorize() {
        if field.tag == 0 {
            self.backgroundColor = freetime_color
        }
        else {
            self.backgroundColor = color_pallette[field.tag % color_pallette.count]
        }
    }
}
