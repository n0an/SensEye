//
//  PostView.swift
//  SensEye
//
//  Created by Anton Novoselov on 30/12/2016.
//  Copyright © 2016 Anton Novoselov. All rights reserved.
//

import UIKit

class PostView: UIView {
    
    var cornerRadius: CGFloat = 4.0
    
    var shadowWidth: CGFloat = 0
    var shadowHeight: CGFloat = 2.0
    var shadowOpacity: Float = 0.3
    var shadowColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        layer.cornerRadius = cornerRadius
        layer.masksToBounds = false
        
        let shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius)
        layer.shadowColor = shadowColor.cgColor
        layer.shadowOffset = CGSize(width: shadowWidth, height: shadowHeight)
        layer.shadowOpacity = shadowOpacity
        layer.shadowPath = shadowPath.cgPath
        
    }
    
}
