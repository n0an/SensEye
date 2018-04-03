//
//  UIView+shadow.swift
//  SensEye
//
//  Created by Anton Novoselov on 03/04/2018.
//  Copyright © 2018 Anton Novoselov. All rights reserved.
//

import UIKit

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
