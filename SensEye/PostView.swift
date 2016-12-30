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
    
    var shadowWidth: CGFloat = 1.0
    var shadowHeight: CGFloat = 2.0
    var shadowOpacity: Float = 0.7
    var shadowColor = UIColor(colorLiteralRed: 120/255, green: 120/255, blue: 120/255, alpha: 0.6)
    var shadowRadius: CGFloat = 3.0
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        layer.cornerRadius = cornerRadius

        layer.shadowColor = shadowColor.cgColor
        layer.shadowOpacity = shadowOpacity
        
        layer.shadowOffset = CGSize(width: shadowWidth, height: shadowHeight)
        layer.shadowRadius = shadowRadius

        layer.masksToBounds = false
    }
    
}
