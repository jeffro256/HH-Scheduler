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

    public override func viewDidLoad() {
        super.viewDidLoad()

        _ = ContextSchedule(jsonURL: URL(string: "http://jeffaryan.com/schedule_keeper/hh_schedule_info.json")!)
    }
}
