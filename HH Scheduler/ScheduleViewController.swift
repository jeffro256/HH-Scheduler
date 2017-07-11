//
//  ScheduleViewController.swift
//  HH Scheduler
//
//  Created by Jeffrey Ryan on 9/3/16.
//  Copyright © 2016 Jeffrey Ryan. All rights reserved.
//

import UIKit

class ScheduleViewController: UIViewController, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    @IBOutlet weak var schedule_view: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()

        addGradient(to: self.view)

        if schedule == nil {
            schedule = Schedule.defaultLoadFromFile(schedule_file_url)
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)

        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: nil, action: nil)
    }

    // tell the collection view how many cells to make
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 7 * 18
    }

    // make a cell for each cell index path
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // get a reference to our storyboard cell
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ClassCell", for: indexPath) as! ClassCell

        if (indexPath.item % 7 == 0) {
            cell.label.text = String(describing: indexPath.item / 7 + 1)
            cell.backgroundColor = UIColor(red: 0.4, green: 0.4, blue: 0.4, alpha: 1.0)
        }
        else {
            let day = (indexPath.item - indexPath.item / 7 - 1) % 6
            let mod = (indexPath.item - indexPath.item / 7 - 1) / 6
            let class_index = schedule.classes[day][mod]
            cell.label.text = schedule.class_names[class_index]
            srand48(class_index * 100)
            let r = drand48()
            let g = drand48()
            let b = drand48()
            cell.backgroundColor = UIColor(red: CGFloat(r), green: CGFloat(g), blue: CGFloat(b), alpha: 1.0)
        }

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let top_cell_height: CGFloat = 40
        let class_cell_height = floor((schedule_view.frame.height - top_cell_height) / 6)
        let class_cell_height_bottom = schedule_view.frame.height - top_cell_height - class_cell_height * 5

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
}
