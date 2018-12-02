//
//  NotificationPermViewController.swift
//  HH Scheduler
//
//  Created by Jeffrey Ryan on 11/5/18.
//  Copyright © 2018 Jeffrey Ryan. All rights reserved.
//

import UIKit

class NotificationPermViewController: UIViewController {
    @IBOutlet weak var phoneContainer: UIView!
    @IBOutlet weak var notificationImage: UIImageView!
    @IBOutlet weak var notificationYConstraint: NSLayoutConstraint!
    @IBOutlet weak var topSpacingConstraint: NSLayoutConstraint!

    private let segueID = "ToLoad"
    private let notifAnimaDur: TimeInterval = 1.0

    public override func viewWillAppear(_ animated: Bool) {
        notificationImage.alpha = 0

        if UIScreen.main.bounds.height <= 568 {
            topSpacingConstraint.constant = 25 // arbitrary, looks nice
        }
    }

    public override func viewDidAppear(_ animated: Bool) {
        let timer = Timer.scheduledTimer(timeInterval: notifAnimaDur + 2.0, target: self, selector: #selector(animateNotification), userInfo: nil, repeats: true)
        timer.fire()
    }

    @objc
    public func animateNotification() {
        let phoneImageHeight = phoneContainer.frame.height
        let heightRatio: CGFloat = 288.0 / 744.0 // Magic position to place notification image
        let endYConstant = phoneImageHeight * heightRatio
        let delay: TimeInterval = 0.75

        notificationImage.alpha = 0

        let startYConstant = notificationImage.frame.height * 1.5 // arbitrary
        notificationYConstraint.constant = startYConstant
        self.view.layoutIfNeeded()

        self.notificationYConstraint.constant = endYConstant

        UIView.animate(withDuration: notifAnimaDur, delay: delay, options: [.curveEaseInOut], animations: {
            self.view.layoutIfNeeded()
            self.notificationImage.alpha = 1
        }, completion: nil)
    }

    @IBAction func enableNotifications(_ sender: Any) {
        NotificationController.current().requestNotificationPermission(forced: true)

        self.performSegue(withIdentifier: segueID, sender: nil)
    }

    @IBAction func maybeLater(_ sender: Any) {
        self.performSegue(withIdentifier: segueID, sender: nil)
    }
}
