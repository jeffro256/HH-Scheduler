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
    @IBOutlet var startTimeLabelY: NSLayoutConstraint!
    @IBOutlet var endTimeLabelY: NSLayoutConstraint!
    
    private var isVisible = false

    private let niceDateFormatter: DateFormatter = {
        let a = DateFormatter()
        a.dateFormat = "EEEE, MMMM d"
        a.locale = Locale(identifier: "en_US")
        a.timeZone = TimeZone(abbreviation: "CST")

        return a
    }()

    private let niceTimeFormatter: DateFormatter = {
        let a = DateFormatter()
        a.dateFormat = "h:mm aa"
        a.locale = Locale(identifier: "en_US")
        a.timeZone = TimeZone(abbreviation: "CST")

        return a
    }()

    public override func viewDidLoad() {
        super.viewDidLoad()

        updateUI()
        progressRing.value = 0

        Timer.scheduledTimer(withTimeInterval: 1.5, repeats: true) { _ in
            if (self.isVisible) {
                self.updateUI(animated: false)
            }
        }
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.isVisible = true
        updateUI(animated: true)

        futureClassCollection.reloadData()
    }

    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
            self.futureClassCollection.centerCurrentClass()
        })
    }

    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        self.isVisible = false
    }

    private var didLayout = false

    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        if !didLayout {
            let topCollectionBorderWidth = CGFloat(0.5)
            let topCollectionBorderFrame = CGRect(x: 0, y: futureClassCollection.frame.minY - topCollectionBorderWidth, width: self.view.frame.width, height: topCollectionBorderWidth)
            let topCollectionBorder = UIView(frame: topCollectionBorderFrame)
            topCollectionBorder.isOpaque = true
            topCollectionBorder.backgroundColor = UIColor.darkGray
            topCollectionBorder.layer.zPosition = 1

            self.view.addSubview(topCollectionBorder)
        }

        let unitYPosition = sin(-15 * CGFloat.pi / 180)
        let yConstant = progressRing.frame.width / 2 * (1 - unitYPosition) + 20

        startTimeLabelY.constant = yConstant
        endTimeLabelY.constant = yConstant

        // I have to have this code b/c some random black box is popping up
        for view in progressRing.subviews {
            if view.tag == 0 {
                view.removeFromSuperview()
            }
        }

        didLayout = true
    }

    private var updatingUI = false

    private func updateUI(animated: Bool = false) {
        if updatingUI { return }
        updatingUI = true

        let now = Date()
        let nowTime = Calendar.current.date(from: Calendar.current.dateComponents([.hour, .minute, .second], from: now))!

        let dateText = niceDateFormatter.string(from: now)
        let dayShortDesc: String
        var mainText = ""
        var modText = ""
        var startTimeText = ""
        var endTimeText = ""

        progressRing.value = progressRing.minValue

        if scheduleContext.isScheduledDay(now) {
            let cycleCharacter = Character(UnicodeScalar(Int(("A" as UnicodeScalar).value) + scheduleContext.getCycleDay(now))!)
            dayShortDesc = "\(cycleCharacter) DAY"

            let blocks = scheduleContext.getBlocks(now, from: schedule)

            if Calendar.current.compare(nowTime, to: scheduleContext.getStartTime(now)!, toGranularity: .minute) == .orderedAscending {
                mainText = "Good Morning!"
            }
            else if Calendar.current.compare(nowTime, to: scheduleContext.getEndTime(now)!, toGranularity: .minute) != .orderedAscending {
                mainText = "School is Over!"
            }
            else {
                for (i, block) in blocks.enumerated() {
                    if nowTime >= block.startTime && nowTime < block.endTime {
                        let classID = block.scheduleClass.classID
                        mainText = block.scheduleClass.name
                        progressRing.innerRingColor = block.scheduleClass.color

                        if let mod = block.mod {
                            modText = "Mod \(mod+1)"
                        }

                        var classStartTime = block.startTime
                        var classEndTime = block.endTime

                        for prevBlock in blocks[0..<i].reversed() {
                            if prevBlock.scheduleClass.classID == classID {
                                classStartTime = prevBlock.startTime
                            }
                            else {
                                break
                            }
                        }

                        for nextBlock in blocks[(i+1)..<blocks.count] {
                            if nextBlock.scheduleClass.classID == classID {
                                classEndTime = nextBlock.endTime
                            }
                            else {
                                break
                            }
                        }

                        startTimeText = niceTimeFormatter.string(from: classStartTime)
                        endTimeText = niceTimeFormatter.string(from: classEndTime)

                        let totalSecondsInClass = Calendar.current.dateComponents([.second], from: classStartTime, to: classEndTime).second!
                        let secondSinceClassStart = Calendar.current.dateComponents([.second], from: classStartTime, to: nowTime).second!
                        let ratioDoneWithClass = CGFloat(secondSinceClassStart) / CGFloat(totalSecondsInClass)
                        let ringProgress = progressRing.minValue + (progressRing.maxValue - progressRing.minValue) * ratioDoneWithClass

                        if animated {
                            progressRing.setProgress(value: ringProgress, animationDuration: 1)
                        }
                        else {
                            progressRing.value = ringProgress
                        }

                        break
                    }
                }
            }
        }
        else if scheduleContext.isSchoolDay(now) {
            dayShortDesc = "Weird Day"
            mainText = scheduleContext.getWeirdDayName(now)!
        }
        else if scheduleContext.isHoliday(now) {
            dayShortDesc = "Day Off"
        }
        else if !scheduleContext.isInSchoolYear(now) {
            dayShortDesc = "Summer"
        }
        else { // I assume it's the weekend
            dayShortDesc = "Weekend"
        }

        for label in labels {
            switch label.tag {
            case 50:
                label.isHidden = !scheduleContext.isWeirdDay(now)
            case 51:
                label.text = dateText
            case 52:
                label.text = dayShortDesc
            case 53:
                label.text = mainText
            case 54:
                label.text = modText
            case 55:
                label.text = startTimeText
                break
            case 56:
                label.text = endTimeText
                break
            default:
                break
            }
        }

        updatingUI = false
    }
}

class FutureClassCollection: UICollectionView, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    private var classes = [(Int, String, Date, Date, UIColor)]()

    private let niceTimeFormatter: DateFormatter = {
        let a = DateFormatter()
        a.dateFormat = "h:mm aa"
        a.locale = Locale(identifier: "en_US")
        a.timeZone = TimeZone(abbreviation: "CST")

        return a
    }()

    public override func awakeFromNib() {
        super.awakeFromNib()

        self.dataSource = self
        self.delegate = self
    }

    private var addedLabel = false
    public override func layoutSubviews() {
        super.layoutSubviews()

        if !addedLabel {
            self.backgroundView = UIView(frame: self.bounds)
            self.backgroundView?.backgroundColor = UIColor.white

            let noClassesLabelFrame = self.backgroundView!.bounds
            let noClassesLabel = UILabel(frame: noClassesLabelFrame)
            noClassesLabel.tag = 1
            noClassesLabel.text = "No Classes Today!"
            noClassesLabel.textAlignment = .center
            noClassesLabel.textColor = UIColor.black
            noClassesLabel.font = UIFont(name: "Avenir-LightOblique", size: 18)
            noClassesLabel.isHidden = !classes.isEmpty

            self.backgroundView?.addSubview(noClassesLabel)

            addedLabel = true
        }
    }

    public func centerCurrentClass() {
        let now = Date()
        let nowTime = Calendar.current.date(from: Calendar.current.dateComponents([.hour, .minute, .second], from: now))!

        if let currentClassIndex = classes.index(where: { nowTime >= $0.2 && nowTime < $0.3 }) {
            self.scrollToItem(at: IndexPath(row: currentClassIndex, section: 0), at: .centeredHorizontally, animated: true)
        }
    }

    public override func reloadData() {
        let blocks = scheduleContext.getBlocks(Date(), from: schedule)

        classes = []

        for block in blocks {
            if classes.count > 0 && block.scheduleClass.classID == classes.last!.0 {
                classes[classes.count-1].3 = block.endTime
            }
            else {
                classes.append((block.scheduleClass.classID, block.scheduleClass.name, block.startTime, block.endTime, block.scheduleClass.color))
            }
        }

        self.backgroundView?.viewWithTag(1)?.isHidden = !classes.isEmpty

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

        if contClass.0 == schedule.freetimeID() {
            updateGradient(cell: cell, color: UIColor(0xE1E1EA))
        }
        else {
            updateGradient(cell: cell, color: contClass.4)
        }

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

    private func updateGradient(cell: FutureClassCell, color color1: UIColor, to toColor: UIColor? = nil) {
        let color2 = toColor ?? color1.hslScale(1, 1, 1.05)

        cell.gradientLayer.colors = [color2.cgColor, color1.cgColor]
    }
}

class FutureClassCell: UICollectionViewCell {
    @IBOutlet weak var startTimeLabel: UILabel!
    @IBOutlet weak var endTimeLabel: UILabel!
    @IBOutlet weak var classLabel: UILabel!

    public var gradientLayer: CAGradientLayer!
}
