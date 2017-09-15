//
//  HomeViewController.swift
//  HH Scheduler
//
//  Created by Jeffrey Ryan on 9/10/17.
//  Copyright © 2017 Jeffrey Ryan. All rights reserved.
//

import UIKit
import UICircularProgressRing

class HomeViewController: UIViewController {
    @IBOutlet weak var progessRing: UICircularProgressRingView!
    @IBOutlet var labels: [UILabel]!

    private var cschedule: ContextSchedule!

    private let niceDateFormatter: DateFormatter = {
        let a = DateFormatter()
        a.dateFormat = "EEEE, MMMM dd"
        a.locale = Locale(identifier: "en_US")
        a.timeZone = TimeZone(abbreviation: "CST")

        return a
    }()

    public override func viewDidLoad() {
        super.viewDidLoad()

        cschedule = ContextSchedule(jsonURL: URL(string: "http://jeffaryan.com/schedule_keeper/hh_schedule_info.json")!)

        updateUI()
    }

    private func updateUI() {
        let now = Date()

        let dateText = niceDateFormatter.string(from: now)

        if cschedule.isScheduledDay(now) {

        }
        else if cschedule.isSchoolDay(now) {

        }
        else if cschedule.isHoliday(now) {

        }
        else if !cschedule.isInSchoolYear(now) {

        }
        else { // I assume it's the weekend

        }

        for label in labels {
            switch label.tag {
            case 50:
                label.isHidden = !cschedule.isWeirdDay(now)
            case 51:
                label.text = dateText
            case 52:
                if cschedule.isScheduledDay(now) {
                    let cycleCharacter = Character(UnicodeScalar(Int(("A" as UnicodeScalar).value) + cschedule.getCycleDay(now))!)
                    label.text = "\(cycleCharacter) DAY"
                }
                else {
                    label.text = ""
                }
            case 53:
                break
            default:
                break
            }
        }
    }
}

class FutureClassCollection: UICollectionView, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    public override func awakeFromNib() {
        super.awakeFromNib()

        self.dataSource = self
        self.delegate = self
    }

    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return collectionView.dequeueReusableCell(withReuseIdentifier: "FutureClassCell", for: indexPath)
    }
}

class FutureClassCell: UICollectionView {

}
