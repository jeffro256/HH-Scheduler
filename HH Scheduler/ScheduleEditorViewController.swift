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

    var class_names: [(String, Int)] = []
    var classes: [[Int]] = []
    var selectedClassCell = 0

    func isLastItem(_ indexPath: IndexPath) -> Bool {
        return indexPath.item == tableView.numberOfRows(inSection: 0) - 1
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        for (i, c) in schedule.class_names.enumerated() {
            class_names.append((c, i))
        }

        classes = schedule.classes

        scheduleCollectionView.scheduleController = self
    }

    private func compressScheduleInfo(_ unordered_class_names: [(String, Int)], _ org_classes: [[Int]]) -> ([String], [[Int]]) {
        let ordered_class_names = unordered_class_names.sorted { $0.1 < $1.1 }

        var flattened_class_names: [String] = []
        var new_classes = org_classes

        for i in 0..<ordered_class_names.count {
            let (class_name, class_indx) = ordered_class_names[i]

            if class_indx != i {
                for day in 0..<6 {
                    for mod in 0..<18 {
                        if new_classes[day][mod] == class_indx {
                            new_classes[day][mod] = i
                        }
                    }
                }
            }

            flattened_class_names.append(class_name)
        }

        return (flattened_class_names, new_classes)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        scheduleCollectionView.reloadData()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)

        if segue.identifier == "Next" {
            let sportController = segue.destination as! SportEditorController

            let (new_class_names, new_classes) = compressScheduleInfo(self.class_names, self.classes)

            self.class_names = new_class_names.enumerated().map { ($0.1, $0.0) }
            self.classes = new_classes

            sportController.setup(self.class_names.map { $0.0 } , self.classes, schedule.sport, schedule.sport_end_time)
        }
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return class_names.count + 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if isLastItem(indexPath) {
            let add_cell = tableView.dequeueReusableCell(withIdentifier: "AddCell")

            return add_cell!
        }
        else {
            let class_info_cell = tableView.dequeueReusableCell(withIdentifier: "ClassInfoCell") as! ClassInfoCell

            class_info_cell.field.text = class_names[indexPath.item].0
            class_info_cell.field.isEnabled = indexPath.item != 0
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

            let highest_class_index = class_names.max { $0.1 < $1.1 }!.1
            let class_index = highest_class_index + 1

            class_names.append(("New Class", class_index))

            tableView.beginUpdates()
            tableView.insertRows(at: [indexPath], with: .automatic)
            tableView.endUpdates()

            tableView.selectRow(at: indexPath, animated: true, scrollPosition: .none)
            selectedClassCell = indexPath.item
        }
        else {
            selectedClassCell = indexPath.item
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
            self.class_names[textField.tag].0 = textField.text!
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
        let class_indx = class_names[indexPath.item].1
        class_names.remove(at: indexPath.item)

        for day in 0..<6 {
            for mod in 0..<18 {
                if classes[day][mod] == class_indx {
                    classes[day][mod] = 0
                }
            }
        }

        // delete the table view row
        tableView.deleteRows(at: [indexPath], with: .fade)
        scheduleCollectionView.reloadData()
    }
}

class ScheduleEditorCollectionView: UICollectionView, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    var scheduleController: ScheduleEditorViewController!

    override func awakeFromNib() {
        super.awakeFromNib()

        self.delegate = self
        self.dataSource = self
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (schedule.sport == nil) ? (7 * 18): (7 * 19)
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ClassCell", for: indexPath) as! ClassCell

        if (indexPath.item % 7 == 0) {
            cell.label.text = String(describing: indexPath.item / 7 + 1)
            cell.backgroundColor = UIColor(red: 0.4, green: 0.4, blue: 0.4, alpha: 1.0)
        }
        else if indexPath.item > 7 * 18 {
            cell.label.text = schedule.sport
            cell.colorize()
            cell.makeBorder()
        }
        else {
            let day = (indexPath.item - indexPath.item / 7 - 1) % 6
            let mod = (indexPath.item - indexPath.item / 7 - 1) / 6
            let class_index = scheduleController.classes[day][mod]
            cell.label.text = scheduleController.class_names.first { $0.1 == class_index }?.0
            cell.colorize()
            cell.makeBorder()
        }

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let top_cell_height: CGFloat = 40
        let class_cell_height = floor((self.frame.height - top_cell_height) / 6)
        let class_cell_height_bottom = self.frame.height - top_cell_height - class_cell_height * 5

        let h: CGFloat

        if indexPath.item % 7 == 0 {
            h = top_cell_height
        }
        else if (indexPath.item - 5) % 7 == 0 {
            h = class_cell_height_bottom
        }
        else {
            h = class_cell_height
        }

        let w = round(class_cell_height * 1.5)

        return CGSize(width: w, height: h)
    }

    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return indexPath.item % 7 != 0 && indexPath.item < 7 * 18
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! ClassCell
        cell.label.text = scheduleController.class_names[scheduleController.selectedClassCell].0
        cell.colorize()

        let day = (indexPath.item - indexPath.item / 7 - 1) % 6
        let mod = (indexPath.item - indexPath.item / 7 - 1) / 6

        scheduleController.classes[day][mod] = scheduleController.class_names[scheduleController.selectedClassCell].1
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
