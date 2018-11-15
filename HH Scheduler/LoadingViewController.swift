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
    }

    public override func viewDidAppear(_ animated: Bool) {
        DispatchQueue.main.async {
            let loadStart = Date().timeIntervalSinceReferenceDate

            let backupExists = FileManager.default.fileExists(atPath: context_cache_file_url.path)
            let maxWait: TimeInterval? = (backupExists) ? 5 : nil

            if !self.tryRefreshingScheduleContext(waitingMax: maxWait) {
                self.loadBackupContext()
            }

            self.activityIndicator.stopAnimating()

            DispatchQueue.main.async {
                NotificationController.current().scheduleNotifications()
            }

            let loadEnd = Date().timeIntervalSinceReferenceDate

            let minWait: Int32 = 1000000
            let elapsed: Int32 = Int32(loadEnd - loadStart) * 1000000
            let timeToSleep = min(minWait - elapsed, minWait)

            if timeToSleep > 0 {
                usleep(UInt32(timeToSleep))
            }

            self.performSegue(withIdentifier: "ToMain", sender: nil)
        }
    }

    @discardableResult
    func tryRefreshingScheduleContext(waitingMax maxWait: TimeInterval? = nil) -> Bool {
        let startTime = Date().timeIntervalSinceReferenceDate
        var timedOut = false

        repeat {
            if let scheduleData = try? Data(contentsOf: schedule_info_web_url) {
                if scheduleContext.refreshContext(contextData: scheduleData) {
                    try! scheduleData.write(to: context_cache_file_url)

                    break
                }
            }

            usleep(500000)

            let elapsed = Date().timeIntervalSinceReferenceDate - startTime
            timedOut = (maxWait == nil) ? false: elapsed > maxWait!
        } while !scheduleContext.isLoaded() && !timedOut

        return scheduleContext.isLoaded()
    }

    func loadBackupContext() {
        if !scheduleContext.isLoaded() {
            let scheduleData = try! Data(contentsOf: context_cache_file_url)

            scheduleContext.refreshContext(contextData: scheduleData)
        }
    }
}
