//
//  UIImage+resize.swift
//  SensEye
//
//  Created by Anton Novoselov on 18/01/2017.
//  Copyright © 2017 Anton Novoselov. All rights reserved.
//

import UIKit

extension UIImage {
    func resized(forHeight height: CGFloat) -> UIImage {
        let ratio = self.size.width / self.size.height
        let width = height * ratio
        let newSize = CGSize(width: width, height: height)
        
        let newRectangle = CGRect(x: 0, y: 0, width: width, height: height)
        
        UIGraphicsBeginImageContext(newSize)
        self.draw(in: newRectangle)
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return resizedImage!
    }
}
