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
    private let animStartDelay: TimeInterval = 0.7
    private let moveAnimDur: TimeInterval = 0.6
    private let animMidDelay: TimeInterval = 1.5
    private let fadeAnimDur: TimeInterval = 1.0
    private let animEndDelay: TimeInterval = 0.5

    public override func viewWillAppear(_ animated: Bool) {
        notificationImage.alpha = 0

        if UIScreen.main.bounds.height <= 568 {
            topSpacingConstraint.constant = 25 // arbitrary, looks nice
        }
    }

    public override func viewDidAppear(_ animated: Bool) {
        let timer = Timer.scheduledTimer(timeInterval: animationCycleDuration(), target: self, selector: #selector(animateNotification), userInfo: nil, repeats: true)
        timer.fire()
    }

    @objc
    public func animateNotification() {
        let phoneImageHeight = phoneContainer.frame.height
        let heightRatio: CGFloat = 288.0 / 744.0 // Magic position to place notification image
        let endYConstant = phoneImageHeight * heightRatio

        notificationImage.alpha = 0

        let startYConstant = notificationImage.frame.height * 1.5 // arbitrary
        notificationYConstraint.constant = startYConstant
        self.view.layoutIfNeeded()

        self.notificationYConstraint.constant = endYConstant

        let animDur = moveAnimDur + animMidDelay + fadeAnimDur
        let relMoveDur: Double = moveAnimDur / animDur
        let relFadeStart: Double = (moveAnimDur + animMidDelay) / animDur
        let relFadeDur: Double = fadeAnimDur / animDur

        UIView.animateKeyframes(withDuration: animDur, delay: animStartDelay, options: [.calculationModeCubic, .layoutSubviews], animations: {
            UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: relMoveDur) {
                self.view.layoutIfNeeded()
                self.notificationImage.alpha = 1
            }

            UIView.addKeyframe(withRelativeStartTime: relFadeStart, relativeDuration: relFadeDur) {
                self.notificationImage.alpha = 0
            }
        }, completion: nil)
    }

    @IBAction func enableNotifications(_ sender: Any) {
        NotificationController.current().requestNotificationPermission(forced: true)

        createStartupFlagFile()

        self.performSegue(withIdentifier: segueID, sender: nil)
    }

    @IBAction func maybeLater(_ sender: Any) {
        createStartupFlagFile()

        self.performSegue(withIdentifier: segueID, sender: nil)
    }

    private func animationCycleDuration() -> TimeInterval {
        return animStartDelay + moveAnimDur + animMidDelay + fadeAnimDur + animEndDelay
    }

    private func createStartupFlagFile() {
        FileManager.default.createFile(atPath: first_startup_flag_url.path, contents: nil, attributes: nil)
    }
}
