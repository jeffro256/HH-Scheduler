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

        newSchedule = schedule
        scheduleCollectionView.setDataSource(scheduleSource: newSchedule)
        scheduleCollectionView.reloadData()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)

        if segue.identifier == "Next" {
            let sportController = segue.destination as! SportEditorController

            sportController.setup(newSchedule.class_names, newSchedule.classes, schedule.sport, schedule.sport_end_time)
        }
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return newSchedule.getNumberClasses() + 1
    }

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

    var selectedFirst = false
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if isLastItem(indexPath) && !selectedFirst {
            tableView.selectRow(at: IndexPath(row: 0, section: 0), animated: true, scrollPosition: .none)
            selectedFirst = true
        }
    }

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

    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if !isLastItem(indexPath) && indexPath.item != 0 {
            let cell = tableView.cellForRow(at: indexPath) as! ClassInfoCell
            cell.field.isEnabled = false
        }
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return indexPath.item != 0 && !isLastItem(indexPath)
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            deleteClass(indexPath)
        }
        else if editingStyle == .insert {
            exit(EXIT_FAILURE)
        }
    }

    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true) // beware, magic!

        return false
    }

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
        return indexPath.item % 7 != 0 && indexPath.item < 7 * 18
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! ScheduleCell
        let class_index = scheduleController.getCurrentSelectedClass()
        if class_index == 0 {
            cell.label.text = nil
            cell.backgroundColor = UIColor(red: 0.937, green: 0.937, blue: 0.957, alpha: 1.0)
        }
        else {
            cell.label.text = scheduleSource.getClassName(index: class_index)
            cell.backgroundColor = cell.label.text?.scalarRandomColor()
        }

        let day = (indexPath.item - indexPath.item / 7 - 1) % 6
        let mod = (indexPath.item - indexPath.item / 7 - 1) / 6

        scheduleSource.setClassIndex(day: day, mod: mod, index: class_index)
    }
}

class ClassInfoCell: UITableViewCell {
    @IBOutlet weak var field: UITextField!

    @IBAction func hitEnter(_ sender: Any) {
        colorize()
    }

    public func colorize() {
        self.backgroundColor = self.field.text?.scalarRandomColor()
    }
}
