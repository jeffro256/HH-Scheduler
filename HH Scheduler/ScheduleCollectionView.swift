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
        return (sport == nil) ? (7 * 18): (7 * 19)
    }

    // make a cell for each cell index path
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ClassCell", for: indexPath) as! ClassCell

        if (indexPath.item % 7 == 0) {
            cell.label.text = String(describing: indexPath.item / 7 + 1)
            cell.backgroundColor = UIColor(red: 0.4, green: 0.4, blue: 0.4, alpha: 1.0)
        }
        else if indexPath.item > 7 * 18 {
            cell.label.text = sport
            cell.colorize()
            cell.makeBorder()
        }
        else {
            let day = (indexPath.item - indexPath.item / 7 - 1) % 6
            let mod = (indexPath.item - indexPath.item / 7 - 1) / 6
            let class_index = classes[day][mod]
            cell.label.text = class_names[class_index]
            cell.colorize()
            cell.makeBorder()
        }

        return cell
    }

    // Size each cell
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
}

class ClassCell: UICollectionViewCell {
    @IBOutlet weak var label: UILabel!

    public func colorize() {
        self.backgroundColor = label.text?.scalarRandomColor()
    }

    public func makeBorder() {
        self.layer.borderWidth = 0.5
        self.layer.borderColor = UIColor.black.cgColor
    }
}
