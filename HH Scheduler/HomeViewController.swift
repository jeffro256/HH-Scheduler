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

        futureClassCollection.cschedule = cschedule
    }

    public override func viewWillAppear(_ animated: Bool) {
        updateUI()
    }

    var addedNotificationEdge = false
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        if (!addedNotificationEdge) {
            for label in labels {
                if label.tag == 54 {
                    label.layer.zPosition = 2
                    let backView = UIView()
                    let borderWidth = CGFloat(1)
                    backView.backgroundColor = UIColor.black
                    backView.frame = CGRect(x: label.frame.minX, y: label.frame.minY - borderWidth, width: label.frame.width, height: label.frame.height + 2 * borderWidth)
                    backView.layer.zPosition = 1
                    label.superview?.addSubview(backView)
                    addedNotificationEdge = true
                    break
                }
            }
        }
    }

    private func updateUI() {
        let now = Date()

        let nowTime = Calendar.current.date(from: Calendar.current.dateComponents([.hour, .minute], from: now))!

        let dateText = niceDateFormatter.string(from: now)
        let dayShortDesc: String
        var mainText = ""

        if cschedule.isScheduledDay(now) {
            let cycleCharacter = Character(UnicodeScalar(Int(("A" as UnicodeScalar).value) + cschedule.getCycleDay(now))!)
            dayShortDesc = "\(cycleCharacter) DAY"

            let blocks = cschedule.getBlocks(now, from: schedule)

            for block in blocks {
                if nowTime > block.startTime {
                    mainText = block.name
                    progessRing.innerRingColor = block.color
                    break
                }
            }
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
            case 54:
                // notifications
                break
            default:
                break
            }
        }
    }
}

class FutureClassCollection: UICollectionView, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    public var cschedule: ContextSchedule!

    private var loadDate: Date!

    public override func awakeFromNib() {
        super.awakeFromNib()

        self.dataSource = self
        self.delegate = self
    }

    public override func reloadData() {
        loadDate = Date()

        super.reloadData()
    }

    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cschedule.getBlocks(Date(), from: schedule).count
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        return collectionView.dequeueReusableCell(withReuseIdentifier: "FutureClassCell", for: indexPath)
    }
}

class FutureClassCell: UICollectionViewCell {
    @IBOutlet weak var startTimeLabel: UILabel!
    @IBOutlet weak var endTimeLabel: UILabel!
    @IBOutlet weak var classLabel: UILabel!
}
