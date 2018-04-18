//
//  FancyButton.swift
//  SensEye
//
//  Created by Anton Novoselov on 16/01/2017.
//  Copyright © 2017 Anton Novoselov. All rights reserved.
//

import UIKit

@IBDesignable
class FancyButton: UIButton {

    // MARK: - IBInspectable PROPERTIES
    @IBInspectable var cornerRadius: Double = 0.0 {
        didSet {
            layer.cornerRadius = CGFloat(cornerRadius)
            layer.masksToBounds = true
        }
    }
    
    @IBInspectable var borderWidth: Double = 0.0 {
        didSet {
            layer.borderWidth = CGFloat(borderWidth)
        }
    }
    
    @IBInspectable var borderColor: UIColor = .black {
        didSet {
            layer.borderColor = borderColor.cgColor
        }
    }
    
    @IBInspectable var titleLeftPadding: Double = 0.0 {
        didSet {
            titleEdgeInsets.left = CGFloat(titleLeftPadding)
        }
    }
    
    @IBInspectable var titleRightPadding: Double = 0.0 {
        didSet {
            titleEdgeInsets.right = CGFloat(titleRightPadding)
        }
    }
    
    @IBInspectable var titleTopPadding: Double = 0.0 {
        didSet {
            titleEdgeInsets.top = CGFloat(titleTopPadding)
        }
    }
    
    @IBInspectable var titleBottomPadding: Double = 0.0 {
        didSet {
            titleEdgeInsets.bottom = CGFloat(titleBottomPadding)
        }
    }
    
    @IBInspectable var imageLeftPadding: Double = 0.0 {
        didSet {
            if !enableImageRightAligned {
                imageEdgeInsets.left = CGFloat(imageLeftPadding)
            }
        }
    }
    
    @IBInspectable var imageRightPadding: Double = 0.0 {
        didSet {
            imageEdgeInsets.right = CGFloat(imageRightPadding)
        }
    }
    
    @IBInspectable var imageTopPadding: Double = 0.0 {
        didSet {
            imageEdgeInsets.top = CGFloat(imageTopPadding)
        }
    }
    
    @IBInspectable var imageBottomPadding: Double = 0.0 {
        didSet {
            imageEdgeInsets.bottom = CGFloat(imageBottomPadding)
        }
    }
    
    @IBInspectable var enableImageRightAligned: Bool = false
    @IBInspectable var enableGradientBackground: Bool = false
    @IBInspectable var gradientColor1: UIColor = UIColor.black
    @IBInspectable var gradientColor2: UIColor = UIColor.white
    
    @IBInspectable var startX: Double = 0
    @IBInspectable var startY: Double = 0
    
    @IBInspectable var endX: Double = 0
    @IBInspectable var endY: Double = 1
    
    // MARK: - layoutSubviews
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if enableImageRightAligned,
            let imageView = imageView {
            imageEdgeInsets.left = self.bounds.width - imageView.bounds.width - CGFloat(imageLeftPadding)
        }
        
        if enableGradientBackground {
            //            backgroundColor = UIColor.clear
            let gradientLayer = CAGradientLayer()
            gradientLayer.frame = self.bounds
            
            gradientLayer.colors = [gradientColor1.cgColor, gradientColor2.cgColor]
//            gradientLayer.locations = [0.0, 1.0]
            gradientLayer.startPoint = CGPoint(x: startX, y: startY)
            gradientLayer.endPoint = CGPoint(x: endX, y: endY)
            
            self.layer.insertSublayer(gradientLayer, at: 0)
        }
    }
    
    func flip(delay: CFTimeInterval, duration: CFTimeInterval) {
        guard let layer = self.layer.sublayers?.first as? CAGradientLayer else { return }
        
        let animation = CABasicAnimation(keyPath: "colors")
        
        animation.beginTime = CACurrentMediaTime() + delay
        animation.fromValue = [gradientColor1.cgColor, gradientColor2.cgColor]
        
        (gradientColor1, gradientColor2) = (gradientColor2, gradientColor1)
        
        animation.toValue = [gradientColor1.cgColor, gradientColor2.cgColor]
        
        animation.duration = duration
        
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        
        animation.fillMode = kCAFillModeBackwards
        
        layer.add(animation, forKey: "colors")
        
        layer.colors = [gradientColor1.cgColor, gradientColor2.cgColor]
    }
    
    
    
}
