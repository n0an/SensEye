//
//  NSDate+stringFromDate.swift
//  SensEye
//
//  Created by Anton Novoselov on 03/04/2018.
//  Copyright © 2018 Anton Novoselov. All rights reserved.
//

import Foundation

// MARK: - NSDATE EXTENSION
extension NSDate {
    func stringFromDate(short: Bool) -> String {
        let interval = NSDate().days(after: self as Date?)
        var dateString = ""
        
        if interval == 0 {
            dateString = NSLocalizedString("Today", comment: "Today")
        } else if interval == 1 {
            dateString = NSLocalizedString("Yesterday", comment: "Yesterday")
            
        } else if interval > 1 {
            let dateFormat = DateFormatter()
            
            dateFormat.dateFormat = short ? "dd.MM.yyyy" : "dd MMMM yyyy"
            dateString = dateFormat.string(from: self as Date)
        }
        
        return dateString
    }
}
