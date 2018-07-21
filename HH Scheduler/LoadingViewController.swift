//
//  LoadingViewController.swift
//  HH Scheduler
//
//  Created by Jeffrey Ryan on 11/9/17.
//  Copyright © 2017 Jeffrey Ryan. All rights reserved.
//

import UIKit
import NVActivityIndicatorView

class LoadingViewController: UIViewController {
    @IBOutlet weak var activityIndicator: NVActivityIndicatorView!

    public override func viewDidLoad() {
        super.viewDidLoad()

        self.activityIndicator.startAnimating()

        DispatchQueue.main.async {
            let loadStart = Date().timeIntervalSinceReferenceDate
            while !scheduleContext.isLoaded() {
                scheduleContext.refreshContextURL(schedule_info_web_url)

                usleep(100000)
            }

            self.activityIndicator.stopAnimating()

            let loadEnd = Date().timeIntervalSinceReferenceDate

            let maxWait: UInt32 = 1500000
            let timeToSleep = min(maxWait - UInt32((loadEnd - loadStart) * 1000000), maxWait)

            if timeToSleep > 0 {
                usleep(timeToSleep)
            }

            self.performSegue(withIdentifier: "DoneLoading", sender: nil)
        }
    }
}
