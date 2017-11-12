//
//  ClassManagerViewController.swift
//  HH Scheduler
//
//  Created by Jeffrey Ryan on 10/14/17.
//  Copyright © 2017 Jeffrey Ryan. All rights reserved.
//

import UIKit

class ClassManagerViewController: UITableViewController {
    public var pschedule: PSchedule!

    public override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.isEditing = true
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.pschedule.getNumClasses()
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ClassManageCell") as! ClassManageCell

        let classInfo = pschedule.getClassInfo(withID: pschedule.getClassID(index: indexPath.item))!

        cell.nameLabel.text = classInfo.name
        cell.colorView.backgroundColor = classInfo.color

        if pschedule.getClassInfo(withID: pschedule.freetimeID())!.classIndex == indexPath.item {
            cell.accessoryType = .none
            cell.editingAccessoryType = .none
        }

        return cell
    }

    override func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        let isFreetime = pschedule.getClassInfo(withID: pschedule.freetimeID())!.classIndex == indexPath.item
        return isFreetime ? .none : .delete
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        pschedule.removeClass(withID: pschedule.getClassID(index: indexPath.item))
        tableView.beginUpdates()
        tableView.deleteRows(at: [indexPath], with: .automatic)
        tableView.endUpdates()

        try? pschedule.saveToFile(schedule_file_url)
    }

    override func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return (pschedule.getClassInfo(withID: pschedule.freetimeID())!.classIndex != indexPath.item)
    }

    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        return (pschedule.getClassInfo(withID: pschedule.freetimeID())!.classIndex == indexPath.item) ? nil : indexPath
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let vc = self.storyboard!.instantiateViewController(withIdentifier: "ClassEditVC") as! ClassEditorViewController

        let classInfo = pschedule.getClassInfo(withID: pschedule.getClassID(index: indexPath.item))!
        vc.classID = classInfo.classID
        vc.startName = classInfo.name
        vc.startColorIndex = color_pallette.index(where: { classInfo.color.asInt32() == $0.asInt32() })

        self.navigationController?.pushViewController(vc, animated: true)
    }

    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        pschedule.setClassIndex(withID: pschedule.getClassID(index: sourceIndexPath.item), to: destinationIndexPath.item)
        try? pschedule.saveToFile(schedule_file_url)
    }

    @IBAction func addButtonPressed(_ sender: Any) {
        let vc = self.storyboard!.instantiateViewController(withIdentifier: "ClassEditVC") as! ClassEditorViewController

        vc.adding = true

        self.navigationController?.pushViewController(vc, animated: true)
    }

    @IBAction public func doneEditingClass(_ segue: UIStoryboardSegue) {
        let vc = segue.source as! ClassEditorViewController

        let (name, color) = vc.getData()
        if vc.adding {
            let addPath = IndexPath(row: self.tableView.numberOfRows(inSection: 0), section: 0)
            self.tableView.beginUpdates()
            pschedule.addClass(withName: name, color: color)
            self.tableView.insertRows(at: [addPath], with: .automatic)
            self.tableView.endUpdates()
        }
        else {
            pschedule.setClassName(withID: vc.classID, to: name)
            pschedule.setClassColor(withID: vc.classID, to: color)

            let cell = self.tableView.cellForRow(at: IndexPath(row: pschedule.getClassInfo(withID: vc.classID)!.classIndex, section: 0)) as! ClassManageCell

            cell.nameLabel.text = name
            cell.colorView.backgroundColor = color
        }

        try? pschedule.saveToFile(schedule_file_url)
    }

    @IBAction public func deleteClass(_ segue: UIStoryboardSegue) {
        let vc = segue.source as! ClassEditorViewController
        let classIndex = pschedule.getClassInfo(withID: vc.classID)!.classIndex
        pschedule.removeClass(withID: vc.classID)
        tableView.beginUpdates()
        tableView.deleteRows(at: [IndexPath(row: classIndex, section: 0)], with: .bottom)
        tableView.endUpdates()
        try? pschedule.saveToFile(schedule_file_url)
    }
}

class ClassManageCell: UITableViewCell {
    @IBOutlet public weak var colorView: UIView!
    @IBOutlet public weak var nameLabel: UILabel!
}
