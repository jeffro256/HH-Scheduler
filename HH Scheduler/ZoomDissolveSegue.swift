//
//  ZoomDissolveSegue.swift
//  HH Scheduler
//
//  Created by Jeffrey Ryan on 11/5/18.
//  Copyright © 2018 Jeffrey Ryan. All rights reserved.
//

import UIKit

class ZoomDissolveSegue: UIStoryboardSegue {
    override func perform() {
        zoomDissolve()
    }

    func zoomDissolve() {
        let scale: CGFloat = 8.0
        let animDuration: TimeInterval = 0.5

        let toVC = self.destination
        let fromVC = self.source

        let containerView = fromVC.view.superview!

        containerView.insertSubview(toVC.view, belowSubview: fromVC.view)

        UIView.animateKeyframes(withDuration: animDuration, delay: 0, options: .calculationModeCubicPaced, animations: {
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: animDuration) {
                fromVC.view.transform = CGAffineTransform(scaleX: scale, y: scale)
            }

            UIView.addKeyframe(withRelativeStartTime: animDuration * 0.25, relativeDuration: animDuration * 0.75) {
                fromVC.view.alpha = 0
            }
        }, completion: { success in
            fromVC.present(toVC, animated: false, completion: nil)
        })
    }
}
