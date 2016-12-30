//
//  Extensions.swift
//  SensEye
//
//  Created by Anton Novoselov on 30/12/2016.
//  Copyright © 2016 Anton Novoselov. All rights reserved.
//

import UIKit

// MARK: - NSDATE EXTENSION
extension NSDate {
    func stringFromDate() -> String {
        let interval = NSDate().days(after: self as Date!)
        var dateString = ""
        
        if interval == 0 {
            dateString = "Today"
        } else if interval == 1 {
            dateString = "Yesterday"
        } else if interval > 1 {
            let dateFormat = DateFormatter()
            dateFormat.dateFormat = "dd MMMM yyyy"
            dateString = dateFormat.string(from: self as Date)
        }
        return dateString
    }
}

