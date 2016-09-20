//
//  SecondViewController.swift
//  HH Scheduler
//
//  Created by Jeffrey Ryan on 9/3/16.
//  Copyright © 2016 Jeffrey Ryan. All rights reserved.
//

import UIKit

class Schedule: NSObject, NSCoding {
    var classes: [String]
    var schedule: [[Int]]
    var sport: String?
    var sport_times: [Date]?

    override init() {
        classes = ["Free Time"]
        schedule = [[Int]](repeating: [Int](repeating: 0, count: 18), count: 6)
        sport = nil
        sport_times = nil

        super.init()
    }

    static func loadFromFile(_ target: URL) -> Schedule? {
        return NSKeyedUnarchiver.unarchiveObject(withFile: target.path) as? Schedule
    }

    func saveToFile(_ target: URL) throws {
        if !NSKeyedArchiver.archiveRootObject(self, toFile: target.path) {
            throw NSError(domain: "Failed to save schedule to file", code: 2, userInfo: nil)
        }
    }

    required init(coder aDecoder: NSCoder) {
        classes = aDecoder.decodeObject(forKey: "classes") as! [String]
        schedule = aDecoder.decodeObject(forKey: "schedule") as! [[Int]]
        sport = aDecoder.decodeObject(forKey: "sport") as! String?
        sport_times = aDecoder.decodeObject(forKey: "sport_times") as! [Date]?

        super.init()
    }

    func encode(with aCoder: NSCoder) {
        aCoder.encode(classes, forKey: "classes")
        aCoder.encode(schedule, forKey: "schedule")
        aCoder.encode(sport, forKey: "sport")
        aCoder.encode(sport_times, forKey: "sport_times")
    }
}

class ScheduleViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    static var schedule: Schedule?

    override func viewDidLoad() {
        super.viewDidLoad()

        /* RIP Gradient
        let backView = UIView(frame: self.view.frame)
        addGradient(to: backView)
        self.collectionView?.insertSubview(backView, atIndex: 0)
        */

        if ScheduleViewController.schedule == nil {
            ScheduleViewController.loadSchedule()
        }

        try! ScheduleViewController.schedule?.saveToFile(schedule_file_url)
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 6*18;
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let identifier = "schedule_reuse"

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath)

        if let cell_label = cell.viewWithTag(101) as? UILabel {
            cell_label.text = String((indexPath as NSIndexPath).row)
        }

        cell.layer.borderColor = UIColor.black.cgColor
        cell.layer.borderWidth = 0.5

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellHeight = collectionView.frame.height / 6
        let cellWidth = cellHeight * 1.5

        return CGSize(width: cellWidth, height: cellHeight)
    }

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1;
    }

    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "Header", for: indexPath)

        return headerView
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let headerSize = collectionView.frame.width / 5.0
        return CGSize(width: headerSize, height: 0)
    }

    @IBAction func handleSwipes(_ sender: AnyObject) {
        let tabIndex = tabBarController!.selectedIndex

        if (sender.direction == .right && tabIndex > 0) {
            tabBarController!.selectedIndex -= 1
        }

        if (sender.direction == .left && tabIndex < tabBarController!.viewControllers!.count - 1) {
            tabBarController!.selectedIndex += 1
        }
    }

    static func loadSchedule() {
        if let schedule = Schedule.loadFromFile(schedule_file_url) {
            ScheduleViewController.schedule = schedule
        }
        else {
            print("Creating new schedule...")
            ScheduleViewController.schedule = Schedule()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

