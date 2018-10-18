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

            let backupExists = FileManager.default.fileExists(atPath: context_cache_file_url.path)
            let maxTriesWithBackup = 5

            print("backup exists: \(backupExists)")

            var i = 0
            while !backupExists || (backupExists && i < maxTriesWithBackup) {
                print("Requested schedule info.")

                if let scheduleData = try? Data(contentsOf: schedule_info_web_url) {
                    if scheduleContext.refreshContext(contextData: scheduleData) {
                        try! scheduleData.write(to: context_cache_file_url)

                        break
                    }
                }

                sleep(1)
                i += 1
            }

            if !scheduleContext.isLoaded() {
                let scheduleData = try! Data(contentsOf: context_cache_file_url)

                scheduleContext.refreshContext(contextData: scheduleData)
            }

            self.activityIndicator.stopAnimating()

            let loadEnd = Date().timeIntervalSinceReferenceDate

            let maxWait: Int32 = 1000000
            let timeToSleep = min(maxWait - Int32((loadEnd - loadStart) * 1000000), maxWait)

            if timeToSleep > 0 {
                usleep(UInt32(timeToSleep))
            }

            self.performSegue(withIdentifier: "DoneLoading", sender: nil)
        }
    }

    func loadBackupContext() {
        
    }
}
