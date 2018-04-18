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
    
    // MARK: - fadeTo method
    func fadeTo(alphaValue: CGFloat, withDuration duration: TimeInterval) {
        UIView.animate(withDuration: duration) {
            self.alpha = alphaValue
        }
    }
    
    // MARK: - bindToKeyboard feature
    func bindtoKeyboard() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(_:)), name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
    }
    
    @objc func keyboardWillChange(_ notification: NSNotification) {
        let duration = notification.userInfo![UIKeyboardAnimationDurationUserInfoKey] as! Double
        let curve = notification.userInfo![UIKeyboardAnimationCurveUserInfoKey] as! UInt
        let curFrame = (notification.userInfo![UIKeyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        let targetFrame = (notification.userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let deltaY = targetFrame.origin.y - curFrame.origin.y
        
        UIView.animateKeyframes(withDuration: duration, delay: 0.0, options: UIViewKeyframeAnimationOptions(rawValue: curve), animations: {
            self.frame.origin.y += deltaY
        }, completion: nil)
    }
}
