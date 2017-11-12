//
//  MainTabBarContrller.swift
//  HH Scheduler
//
//  Created by Jeffrey Ryan on 11/11/17.
//  Copyright © 2017 Jeffrey Ryan. All rights reserved.
//

import UIKit

class MainTabBarController: UITabBarController, UITabBarControllerDelegate {
    public override func awakeFromNib() {
        super.awakeFromNib()

        self.delegate = self
    }

    public func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        return viewController != tabBarController.selectedViewController
    }
}
