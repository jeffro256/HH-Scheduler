//
//  ScheduleCollectionView.swift
//  HH Scheduler
//
//  Created by Jeffrey Ryan on 7/12/17.
//  Copyright © 2017 Jeffrey Ryan. All rights reserved.
//

import UIKit

class ScheduleCollectionView: UICollectionView, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    var class_names: [String]!
    var classes: [[Int]]!
    var sport: String?
    // tell the collection view how many cells to make

    public override func awakeFromNib() {
        super.awakeFromNib()

        self.delegate = self
        self.dataSource = self
    }

    public func setData(_ class_names: [String], _ classes: [[Int]], _ sport: String? = nil) {
        self.class_names = class_names
        self.classes = classes
        self.sport = sport
    }

    public func getClassNames() -> [String]! {
        return class_names
    }

    public func setClassNames(_ class_names: [String]) {
        self.class_names = class_names
    }

    public func getClasses() -> [[Int]]! {
        return classes
    }

    public func set_Classes(_ classes: [[Int]]) {
        self.classes = classes
    }

    public func getSport() -> String? {
        return sport
    }

    public func set_Sport(_ sport: String) {
        self.sport = sport
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let rows = NUM_DAYS + 1
        return (sport == nil) ? (rows * NUM_MODS): (rows * (NUM_MODS + 1))
    }

    // make a cell for each cell index path
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let rows = NUM_DAYS + 1
        let identifer = (indexPath.item % rows == 0) ? "ModCell" : "ClassCell"
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifer, for: indexPath) as! ScheduleCell

        if indexPath.item == rows * NUM_MODS {
            cell.label.text = "Sport"
        }
        else if (indexPath.item % rows == 0) {
            cell.label.text = String(describing: indexPath.item / rows + 1)
        }
        else if indexPath.item > rows * NUM_MODS {
            cell.label.text = sport
            cell.backgroundColor = cell.label.text?.scalarRandomColor()
        }
        else {
            let day = (indexPath.item - indexPath.item / rows - 1) % NUM_DAYS
            let mod = (indexPath.item - indexPath.item / rows - 1) / NUM_DAYS
            let class_index = classes[day][mod]
            cell.label.text = class_names[class_index]
            cell.backgroundColor = cell.label.text?.scalarRandomColor()
        }

        return cell
    }

    // Size each cell
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let rows = NUM_DAYS + 1
        let top_cell_height: CGFloat = 40
        let class_cell_height = (self.frame.height - top_cell_height) / CGFloat(NUM_DAYS)

        let h: CGFloat

        if indexPath.item % rows == 0 {
            h = top_cell_height
        }
        else {
            let day = CGFloat(indexPath.item % rows - 1)
            h = round(class_cell_height * (day + 1)) - round(class_cell_height * day)
        }

        let w = round(class_cell_height * 1.75)

        return CGSize(width: w, height: h)
    }
}

class ClassCell: UICollectionViewCell {
    @IBOutlet weak var label: UILabel!

    public func colorize() {
        self.backgroundColor = label.text?.scalarRandomColor()
    }
}

class ClassModCell: UICollectionViewCell {
    @IBOutlet weak var label: UILabel!
}

class ScheduleCell: UICollectionViewCell {
    @IBOutlet weak var label: UILabel!
}
