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
            while !scheduleContext.isLoaded() {
                let contextData = (try? Data(contentsOf: schedule_info_web_url)) ?? Data()

                scheduleContext.refreshContext(contextData: contextData)

                sleep(1)
            }

            self.activityIndicator.stopAnimating()

            usleep(500000)
            self.performSegue(withIdentifier: "DoneLoading", sender: nil)
        }
    }
}
