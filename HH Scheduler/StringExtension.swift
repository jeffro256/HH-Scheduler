//
//  StringExtension.swift
//  HH Scheduler
//
//  Created by Jeffrey Ryan on 10/5/16.
//  Copyright © 2016 Jeffrey Ryan. All rights reserved.
//

import UIKit

extension String {
    public func strip() -> String {
        return self.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    }

    public func split(sep: String = " ") -> [String] {
        return self.components(separatedBy: sep)
    }
}
