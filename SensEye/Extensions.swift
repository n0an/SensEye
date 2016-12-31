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

// MARK: - UIColor Extenstion
/** extension to UIColor to allow setting the color
 value by hex value */
extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        /** Verify that we have valid values */
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    /** Initializes and sets color by hex value */
    convenience init(netHex:Int) {
        self.init(red:(netHex >> 16) & 0xff, green:(netHex >> 8) & 0xff, blue:netHex & 0xff)
    }
    
    
}




