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
    var sport_times: [NSDate]?

    override init() {
        classes = ["Free Time"]
        schedule = [[Int]](count: 6, repeatedValue: [Int](count: 18, repeatedValue: 0))
        sport = nil
        sport_times = nil

        super.init()
    }

    static func loadFromFile(target: NSURL) -> Schedule? {
        return NSKeyedUnarchiver.unarchiveObjectWithFile(target.path!) as? Schedule
    }

    func saveToFile(target: NSURL) throws {
        if !NSKeyedArchiver.archiveRootObject(self, toFile: target.path!) {
            throw NSError(domain: "Failed to save schedule to file", code: 2, userInfo: nil)
        }
    }

    required init(coder aDecoder: NSCoder) {
        classes = aDecoder.decodeObjectForKey("classes") as! [String]
        schedule = aDecoder.decodeObjectForKey("schedule") as! [[Int]]
        sport = aDecoder.decodeObjectForKey("sport") as! String?
        sport_times = aDecoder.decodeObjectForKey("sport_times") as! [NSDate]?

        super.init()
    }

    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(classes, forKey: "classes")
        aCoder.encodeObject(schedule, forKey: "schedule")
        aCoder.encodeObject(sport, forKey: "sport")
        aCoder.encodeObject(sport_times, forKey: "sport_times")
    }
}

class ScheduleViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    static var schedule: Schedule?

    private static let headerLength: CGFloat = 150;

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

    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 6*18;
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let identifier = "schedule_reuse"

        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(identifier, forIndexPath: indexPath)

        if let cell_label = cell.viewWithTag(101) as? UILabel {
            cell_label.text = String(indexPath.row)
        }

        cell.layer.borderColor = UIColor.yellowColor().CGColor
        cell.layer.borderWidth = 0.5

        return cell
    }

    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let cellHeight = collectionView.frame.height / 6
        let cellWidth = cellHeight * 1.5

        return CGSizeMake(cellWidth, cellHeight)
    }

    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1;
    }

    override func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        let headerView = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: "Header", forIndexPath: indexPath)

        return headerView
    }

    /*
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSizeMake(ScheduleViewController.headerLength, 0)
    }*/

    @IBAction func handleSwipes(sender: AnyObject) {
        let tabIndex = tabBarController!.selectedIndex

        if (sender.direction == .Right && tabIndex > 0) {
            tabBarController!.selectedIndex -= 1
        }

        if (sender.direction == .Left && tabIndex < tabBarController!.viewControllers!.count - 1) {
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

