//
//  ScheduleCollectionView.swift
//  HH Scheduler
//
//  Created by Jeffrey Ryan on 7/12/17.
//  Copyright © 2017 Jeffrey Ryan. All rights reserved.
//

import UIKit

class ScheduleCollectionView: UICollectionView, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    internal var scheduleSource: ScheduleDataSource!

    public override func awakeFromNib() {
        super.awakeFromNib()

        self.delegate = self
        self.dataSource = self
    }

    public func setDataSource(scheduleSource: ScheduleDataSource) {
        self.scheduleSource = scheduleSource
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let rows = NUM_DAYS + 1
        return (scheduleSource.getSportName() == nil) ? (rows * NUM_MODS): (rows * NUM_MODS + 2)
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
            cell.label.text = scheduleSource.getSportName()
            cell.backgroundColor = cell.label.text?.scalarRandomColor()
        }
        else {
            let day = (indexPath.item - indexPath.item / rows - 1) % NUM_DAYS
            let mod = (indexPath.item - indexPath.item / rows - 1) / NUM_DAYS
            let class_index = scheduleSource.getClassIndex(day: day, mod: mod)

            if class_index == 0 {
                cell.label.text = nil
                cell.backgroundColor = UIColor(red: 0.937, green: 0.937, blue: 0.957, alpha: 1.0)
            }
            else {
                cell.label.text = scheduleSource.getClassName(index: class_index)
                cell.backgroundColor = cell.label.text?.scalarRandomColor()
            }
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
        else if indexPath.item == rows * NUM_MODS + 1 {
            h = self.frame.height - top_cell_height
        }
        else {
            let day = CGFloat(indexPath.item % rows - 1)
            h = round(class_cell_height * (day + 1)) - round(class_cell_height * day)
        }

        let w = round(class_cell_height * 1.75)

        return CGSize(width: w, height: h)
    }
}

class ScheduleCell: UICollectionViewCell {
    @IBOutlet weak var label: UILabel!
}
