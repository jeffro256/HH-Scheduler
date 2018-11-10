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

    private let segueID = "ToLoad"

    public override func viewWillAppear(_ animated: Bool) {
        notificationImage.alpha = 0

        let startYConstant = -notificationImage.frame.height * 1.25 // arbitrary
        notificationYConstraint.constant = startYConstant

        self.view.layoutIfNeeded()
    }

    public override func viewDidAppear(_ animated: Bool) {
        animateNotification()
    }

    func animateNotification() {
        let phoneImageHeight = phoneContainer.frame.height
        let heightRatio: CGFloat = 288.0 / 744.0 // Magic position to place notification image
        let endYConstant = phoneImageHeight * heightRatio
        let duration: TimeInterval = 1.0
        let delay: TimeInterval = 0.75

        self.notificationYConstraint.constant = endYConstant

        UIView.animate(withDuration: duration, delay: delay, options: .curveEaseInOut, animations: {
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
