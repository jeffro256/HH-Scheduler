//
//  ClassEditorViewController.swift
//  HH Scheduler
//
//  Created by Jeffrey Ryan on 7/10/17.
//  Copyright © 2017 Jeffrey Ryan. All rights reserved.
//


import UIKit

class ClassEditorViewController: UITableViewController {
    private var classes: [String] = []
    private var addCell: AddCell!

    func isLastItem(_ indexPath: IndexPath) -> Bool {
        return indexPath.item == tableView.numberOfRows(inSection: 0) - 1
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        classes = schedule.class_names
        classes.remove(at: 0) // Free time
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return classes.count + 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if isLastItem(indexPath) {
            let add_cell = tableView.dequeueReusableCell(withIdentifier: "AddCell") as! AddCell

            self.addCell = add_cell

            return add_cell
        }
        else {
            let class_info_cell = tableView.dequeueReusableCell(withIdentifier: "ClassInfoCell") as! ClassInfoCell

            class_info_cell.field.text = classes[indexPath.item]
            class_info_cell.colorize()

            return class_info_cell
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        classes.append("New Class")

        tableView.beginUpdates()
        tableView.insertRows(at: [indexPath], with: .automatic)
        tableView.endUpdates()
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return indexPath.item != classes.count
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // remove the item from the data model
            classes.remove(at: indexPath.item)

            // delete the table view row
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
        else if editingStyle == .insert {
            exit(EXIT_FAILURE)
        }
    }

    override func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return isLastItem(indexPath)
    }
}

class AddCell: UITableViewCell {

}

class ClassInfoCell: UITableViewCell, UITextFieldDelegate {
    @IBOutlet weak var field: UITextField!

    @IBAction func hitEnter(_ sender: Any) {
        colorize()
    }

    public func colorize() {
        self.backgroundColor = self.field.text?.scalarRandomColor()
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.field.endEditing(true) // beware, magic!
        return false
    }
}
