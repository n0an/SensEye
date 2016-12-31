//
//  PostView.swift
//  SensEye
//
//  Created by Anton Novoselov on 30/12/2016.
//  Copyright © 2016 Anton Novoselov. All rights reserved.
//

import UIKit

@IBDesignable
class PostView: UIView {
    
    @IBInspectable var cornerRadius: CGFloat = 4.0 {
        didSet {
            
            layer.cornerRadius = cornerRadius
            layer.masksToBounds = cornerRadius > 0
            
//            setupView()
        }
    }
    
//    var shadowWidth: CGFloat = 1.0
//    var shadowHeight: CGFloat = 2.0
//    var shadowOpacity: Float = 0.6
//    var shadowColor = mainShadowColor
//    
//    var shadowRadius: CGFloat = 4.0
    
    
//    override func layoutSubviews() {
//        super.layoutSubviews()
//        
//        setupView()
//    }
    
    
//    override func prepareForInterfaceBuilder() {
//        super.prepareForInterfaceBuilder()
//        
//        setupView()
//    }
    
    func setupView() {
        
//        layer.cornerRadius = cornerRadius
//        layer.masksToBounds = false
        
//        layer.shadowColor = shadowColor.cgColor
//        layer.shadowOpacity = shadowOpacity
//        
//        layer.shadowOffset = CGSize(width: shadowWidth, height: shadowHeight)
//        layer.shadowRadius = shadowRadius
        

        
    }
    
}
