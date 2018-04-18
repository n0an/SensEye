//
//  GradientView.swift
//  CALayerTest
//
//  Created by Anton Novoselov on 03/04/2018.
//  Copyright © 2018 Anton Novoselov. All rights reserved.
//

import UIKit

@IBDesignable
class GradientView: UIView {

    @IBInspectable var startColor: UIColor = .white
    @IBInspectable var endColor: UIColor = .black
    
    @IBInspectable var startX: Double = 0
    @IBInspectable var startY: Double = 0

    @IBInspectable var endX: Double = 0
    @IBInspectable var endY: Double = 1
    
    override class var layerClass: AnyClass {
        return CAGradientLayer.self
    }
    
    override func layoutSubviews() {
        guard let layer = layer as? CAGradientLayer else { return }
        
        layer.colors = [startColor.cgColor, endColor.cgColor]
        
        layer.startPoint = CGPoint(x: startX, y: startY)
        layer.endPoint = CGPoint(x: endX, y: endY)
    }

    func flip(delay: CFTimeInterval, duration: CFTimeInterval) {
        guard let layer = layer as? CAGradientLayer else { return }

        let animation = CABasicAnimation(keyPath: "colors")
        
        animation.beginTime = CACurrentMediaTime() + delay
        animation.fromValue = [startColor.cgColor, endColor.cgColor]
        
        (startColor, endColor) = (endColor, startColor)
        
        animation.toValue = [startColor.cgColor, endColor.cgColor]
        
        animation.duration = duration
        
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        
        animation.fillMode = kCAFillModeBackwards
        
        layer.add(animation, forKey: "colors")
        
        layer.colors = [startColor.cgColor, endColor.cgColor]
    }

}
