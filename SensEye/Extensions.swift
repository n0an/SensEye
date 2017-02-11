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
    func stringFromDate(short: Bool) -> String {
        let interval = NSDate().days(after: self as Date!)
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

// MARK: - UIColor Extenstions
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

// MARK: - UIView Shadow Extension
private var shadowEnable = false

extension UIView {
    @IBInspectable var shadowDesign: Bool {
        get {
            return shadowEnable
        }
        
        set {
            shadowEnable = newValue
            
            if shadowEnable {
                self.layer.masksToBounds = false
                
                layer.shadowColor = shadowColor.cgColor
                layer.shadowOpacity = shadowOpacity
                
                layer.shadowOffset = CGSize(width: shadowWidth, height: shadowHeight)
                layer.shadowRadius = shadowRadius
                
            } else {
                self.layer.shadowOpacity = 0.0
                self.layer.shadowRadius = 0.0
                self.layer.shadowColor = nil
            }
        }
    }
    
}

// MARK: - UIAlertController Extension
extension UIAlertController {
    public static func alert(title: String?, message: String?, handler: ((UIAlertAction) -> Void)? = nil) -> UIAlertController {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: handler))
        return alert
    }
    
    public static func alertError(error: NSError, handler: ((UIAlertAction) -> Void)? = nil) -> UIAlertController {
        return UIAlertController.alert(title: error.localizedDescription, message: error.localizedRecoverySuggestion, handler: handler)
    }
    
    public static func confirm(title: String?, message: String?, handler: @escaping (UIAlertAction) -> Void) -> UIAlertController {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("No", comment: "No"), style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: NSLocalizedString("Yes", comment: "Yes"), style: .default, handler: handler))
        return alert
    }
}

extension UIViewController {
    public func alert(title: String?, message: String?, handler: ((UIAlertAction) -> Void)? = nil) {
        let alert = UIAlertController.alert(title: title, message: message, handler: handler)
        present(alert, animated: true, completion: nil)
    }
    
    public func alertError(error: NSError, handler: ((UIAlertAction) -> Void)? = nil) {
        let alert = UIAlertController.alertError(error: error, handler: handler)
        present(alert, animated: true, completion: nil)
    }
    
    public func confirm(title: String?, message: String?, handler: @escaping (UIAlertAction) -> Void) {
        let alert = UIAlertController.confirm(title: title, message: message, handler: handler)
        present(alert, animated: true, completion: nil)
    }
}












