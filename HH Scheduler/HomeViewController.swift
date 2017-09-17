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
    @IBOutlet weak var futureClassCollection: FutureClassCollection!
    @IBOutlet var labels: [UILabel]!

    private var cschedule: ContextSchedule!

    private let niceDateFormatter: DateFormatter = {
        let a = DateFormatter()
        a.dateFormat = "EEEE, MMMM dd"
        a.locale = Locale(identifier: "en_US")
        a.timeZone = TimeZone(abbreviation: "CST")

        return a
    }()

    private let niceTimeFormatter: DateFormatter = {
        let a = DateFormatter()
        a.dateFormat = "hh:mm aa"
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
        let dayShortDesc: String
        let mainText: String

        if cschedule.isScheduledDay(now) {
            let cycleCharacter = Character(UnicodeScalar(Int(("A" as UnicodeScalar).value) + cschedule.getCycleDay(now))!)
            dayShortDesc = "\(cycleCharacter) DAY"
            mainText = "Class"
        }
        else if cschedule.isSchoolDay(now) {
            dayShortDesc = "Weird Day"
            mainText = cschedule.getWeirdDayName(now)!
        }
        else if cschedule.isHoliday(now) {
            dayShortDesc = "Day Off"
            mainText = ""
        }
        else if !cschedule.isInSchoolYear(now) {
            dayShortDesc = "Summer"
            mainText = ""
        }
        else { // I assume it's the weekend
            dayShortDesc = "Weekend"
            mainText = ""
        }

        if !cschedule.isScheduledDay(now) {
            progessRing.value = progessRing.minValue
        }

        for label in labels {
            switch label.tag {
            case 50:
                label.isHidden = !cschedule.isWeirdDay(now)
            case 51:
                label.text = dateText
            case 52:
                label.text = dayShortDesc
            case 53:
                label.text = mainText
            default:
                break
            }
        }

        print("hi")
        let testDateComponents = DateComponents(year: 2017, month: 9, day: 14)
        let testDate = Calendar.current.date(from: testDateComponents)!
        let blocks = cschedule.getBlocks(testDate, from: schedule)

        for block in blocks {
            print(block.name, niceTimeFormatter.string(from: block.startTime), block.mod ?? "-", block.classID)
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
        /*
        let numCells = 0

        if numCells == 0 {
            let noneLabel = UILabel()
            noneLabel.text = "No Classes"
            noneLabel.font = UIFont(name: "Helvetica-LightOblique", size: 17)

            self.backgroundView?.removeFromSuperview()
            self.backgroundView = UIView()
            self.backgroundView?.backgroundColor = UIColor.white
            self.backgroundView?.addSubview(noneLabel)
            noneLabel.center.x = self.backgroundView!.center.x
            noneLabel.center.y = self.backgroundView!.center.y
        }

        return numCells
        */
        return 1
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return collectionView.dequeueReusableCell(withReuseIdentifier: "FutureClassCell", for: indexPath)
    }
}

class FutureClassCell: UICollectionView {

}
