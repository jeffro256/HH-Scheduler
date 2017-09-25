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
        futureClassCollection.reloadData()
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

    private var classes = [(Int, String, Date, Date, UIColor)]()

    private let niceTimeFormatter: DateFormatter = {
        let a = DateFormatter()
        a.dateFormat = "hh:mm aa"
        a.locale = Locale(identifier: "en_US")
        a.timeZone = TimeZone(abbreviation: "CST")

        return a
    }()

    public override func awakeFromNib() {
        super.awakeFromNib()

        self.dataSource = self
        self.delegate = self
    }

    public override func reloadData() {
        let blocks = cschedule.getBlocks(Date(), from: schedule)

        classes = []

        for block in blocks {
            if classes.count > 0 && block.classID == classes.last!.0 {
                classes[classes.count-1].3 = block.endTime
            }
            else {
                classes.append((block.classID, block.name, block.startTime, block.endTime, block.color))
            }
        }

        super.reloadData()
    }

    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return classes.count
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FutureClassCell", for: indexPath) as! FutureClassCell

        let contClass = classes[indexPath.item]

        cell.classLabel.text = contClass.1
        cell.startTimeLabel.text = niceTimeFormatter.string(from: contClass.2)
        cell.endTimeLabel.text = niceTimeFormatter.string(from: contClass.3)

        if cell.gradientLayer == nil {
            addGradient(cell: cell)
        }

        updateGradient(cell: cell, color: contClass.4)

        return cell
    }

    private func addGradient(cell: FutureClassCell) {
        let gradient = CAGradientLayer()
        gradient.colors = [UIColor.white.cgColor, UIColor.gray.cgColor]
        gradient.locations = [0.0, 1.0]
        gradient.startPoint = CGPoint(x: 0.5, y: 0.0)
        gradient.endPoint = CGPoint(x: 0.5, y: 1.0)
        gradient.frame = cell.bounds

        cell.gradientLayer = gradient
        cell.layer.insertSublayer(gradient, at: 0)
    }

    private func updateGradient(cell: FutureClassCell, color color1: UIColor) {
        var hue: CGFloat = 0
        var sat: CGFloat = 0
        var lum: CGFloat = 0
        var alpha: CGFloat = 0
        color1.getHue(&hue, saturation: &sat, brightness: &lum, alpha: &alpha)
        let color2 = UIColor(hue: hue, saturation: sat, brightness: lum * 1.1, alpha: alpha)

        cell.gradientLayer.colors = [color2.cgColor, color1.cgColor]
    }
}

class FutureClassCell: UICollectionViewCell {
    @IBOutlet weak var startTimeLabel: UILabel!
    @IBOutlet weak var endTimeLabel: UILabel!
    @IBOutlet weak var classLabel: UILabel!

    public var gradientLayer: CAGradientLayer!
}
