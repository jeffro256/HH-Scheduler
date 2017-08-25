//
//  SportEditorController.swift
//  HH Scheduler
//
//  Created by Jeffrey Ryan on 7/14/17.
//  Copyright © 2017 Jeffrey Ryan. All rights reserved.
//

import UIKit

class SportEditorController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var sportSwitch: UISwitch!

    private var class_names: [String]!
    private var classes: [[Int]]!
    private var entrySport: String!
    private var entrySportEndTime: Date!

    override func viewDidLoad() {
        super.viewDidLoad()

        addGradient(to: self.view)

        if entrySport != nil {
            sportSwitch.setOn(true, animated: true)
            textField.isEnabled = true
            textField.text = entrySport
            datePicker.isEnabled = true
            datePicker.setDate(entrySportEndTime, animated: true)
        }
        else {
            sportSwitch.setOn(false, animated: true)
            textField.isEnabled = false
            textField.text = nil
            datePicker.isEnabled = false
            datePicker.setDate(Date(), animated: true)
        }
    }

    func setup(_ class_names: [String], _ classes: [[Int]], _ sport: String? = nil, _ sport_end_time: Date? = nil) {
        self.class_names = class_names
        self.classes = classes
        self.entrySport = sport
        self.entrySportEndTime = sport_end_time
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func sportSwitch(_ sender: UISwitch) {
        if sender.isOn {
            textField.isEnabled = true
            datePicker.isEnabled = true
        }
        else {
            textField.isEnabled = false
            datePicker.isEnabled = false
        }
    }
    
    @IBAction func pressedSave(_ sender: Any) {
        let picker_date_components = Calendar.current.dateComponents([.hour, .minute], from:  datePicker.date)
        let picker_date = Calendar.current.date(from: picker_date_components)!

        if sportSwitch.isOn {
            schedule = Schedule(class_names: self.class_names, classes: self.classes, sport: textField.text, sport_end_time: picker_date)
        }
        else {
            schedule = Schedule(class_names: self.class_names, classes: self.classes)
        }

        try! schedule.saveToFile(schedule_file_url)

        navigationController?.popToViewController((navigationController?.viewControllers.first)!, animated: true)
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)

        return false
    }
}
