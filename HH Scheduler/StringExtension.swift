//
//  StringExtension.swift
//  HH Scheduler
//
//  Created by Jeffrey Ryan on 10/5/16.
//  Copyright © 2016 Jeffrey Ryan. All rights reserved.
//

import Foundation

extension String {
    public func strip() -> String {
        return self.trimmingCharacters(in: CharacterSet.whitespaces)
    }
}
