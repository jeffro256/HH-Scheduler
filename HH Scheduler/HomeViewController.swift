//
//  HomeViewController.swift
//  HH Scheduler
//
//  Created by Jeffrey Ryan on 9/10/17.
//  Copyright © 2017 Jeffrey Ryan.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

import UIKit
import UICircularProgressRing

class HomeViewController: UIViewController {
    @IBOutlet weak var progressRing: UICircularProgressRingView!
    @IBOutlet weak var futureClassCollection: FutureClassCollection!
    @IBOutlet var labels: [UILabel]!

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
    }

    public override func viewWillAppear(_ animated: Bool) {
        updateUI()
        futureClassCollection.reloadData()
        futureClassCollection.centerCurrentClass()
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

        // I have to have this code b/c some random black box is popping up
        for view in progressRing.subviews {
            if view.tag == 0 {
                view.removeFromSuperview()
            }
        }
    }

    private func updateUI() {
        let now = Date()
        let nowTime = Calendar.current.date(from: Calendar.current.dateComponents([.hour, .minute, .second], from: now))!

        let dateText = niceDateFormatter.string(from: now)
        let dayShortDesc: String
        var mainText = ""
        var modText = ""

        progressRing.value = progressRing.minValue

        if cschedule.isScheduledDay(now) {
            let cycleCharacter = Character(UnicodeScalar(Int(("A" as UnicodeScalar).value) + cschedule.getCycleDay(now))!)
            dayShortDesc = "\(cycleCharacter) DAY"

            let blocks = cschedule.getBlocks(now, from: schedule)

            if Calendar.current.compare(nowTime, to: cschedule.getStartTime(now)!, toGranularity: .minute) == .orderedAscending {
                mainText = "Good Morning!"
            }
            else if Calendar.current.compare(nowTime, to: cschedule.getEndTime(now)!, toGranularity: .minute) != .orderedAscending {
                mainText = "School is Over!"
            }
            else {
                for (i, block) in blocks.enumerated() {
                    if nowTime >= block.startTime && nowTime < block.endTime {
                        let classID = block.classID
                        mainText = block.name
                        progressRing.innerRingColor = block.color

                        if let mod = block.mod {
                            modText = "Mod \(mod+1)"
                        }

                        var classStartTime = block.startTime
                        var classEndTime = block.endTime

                        for prevBlock in blocks[0..<i].reversed() {
                            if prevBlock.classID == classID {
                                classStartTime = prevBlock.startTime
                            }
                            else {
                                break
                            }
                        }

                        for nextBlock in blocks[(i+1)..<blocks.count] {
                            if nextBlock.classID == classID {
                                classEndTime = nextBlock.endTime
                            }
                            else {
                                break
                            }
                        }

                        let totalSecondsInClass = Calendar.current.dateComponents([.second], from: classStartTime, to: classEndTime).second!
                        let secondSinceClassStart = Calendar.current.dateComponents([.second], from: classStartTime, to: nowTime).second!
                        let ratioDoneWithClass = CGFloat(secondSinceClassStart) / CGFloat(totalSecondsInClass)
                        progressRing.value = progressRing.minValue + (progressRing.maxValue - progressRing.minValue) * ratioDoneWithClass

                        print(ratioDoneWithClass * 100)

                        break
                    }
                }
            }
        }
        else if cschedule.isSchoolDay(now) {
            dayShortDesc = "Weird Day"
            mainText = cschedule.getWeirdDayName(now)!
        }
        else if cschedule.isHoliday(now) {
            dayShortDesc = "Day Off"
        }
        else if !cschedule.isInSchoolYear(now) {
            dayShortDesc = "Summer"
        }
        else { // I assume it's the weekend
            dayShortDesc = "Weekend"
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
                label.text = modText
            default:
                break
            }
        }
    }
}

class FutureClassCollection: UICollectionView, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
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

    public func centerCurrentClass() {
        var currentClassIndex = -1

        let now = Date()
        let nowTime = Calendar.current.date(from: Calendar.current.dateComponents([.hour, .minute, .second], from: now))!

        for (i, contClass) in classes.enumerated() {
            if nowTime >= contClass.2 && nowTime < contClass.3 {
                currentClassIndex = i
                break
            }
        }

        if currentClassIndex >= 0 {
            self.scrollToItem(at: IndexPath(row: currentClassIndex, section: 0), at: .centeredHorizontally, animated: true)
        }
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

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let w = CGFloat(250)
        let h = collectionView.frame.height - 10

        return CGSize(width: w, height: h)
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
        let color2 = UIColor(hue: hue, saturation: sat, brightness: lum * 0.9, alpha: alpha)

        cell.gradientLayer.colors = [color2.cgColor, color1.cgColor]
    }
}

class FutureClassCell: UICollectionViewCell {
    @IBOutlet weak var startTimeLabel: UILabel!
    @IBOutlet weak var endTimeLabel: UILabel!
    @IBOutlet weak var classLabel: UILabel!

    public var gradientLayer: CAGradientLayer!
}
