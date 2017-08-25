//
//  AddGradient.swift
//  HH Scheduler
//
//  Created by Jeffrey Ryan on 9/5/16.
//  Copyright © 2016 Jeffrey Ryan. All rights reserved.
//

import UIKit

func addGradient(to view: UIView) {
    let gradient = CAGradientLayer()
    let color1 = UIColor(red: 172.0 / 255.0, green: 30.0 / 255.0, blue: 40.0 / 255.0, alpha: 1.0).cgColor
    let color2 = UIColor(red: 0.4, green: 0.1, blue: 0.1, alpha: 1.0).cgColor
    gradient.colors = [color1, color2]
    gradient.locations = [0.0, 1.0]
    gradient.startPoint = CGPoint(x: 0.5, y: 0.0)
    gradient.endPoint = CGPoint(x: 0.5, y: 1.0)
    gradient.frame = view.frame

    view.layer.insertSublayer(gradient, at: 0)
}
