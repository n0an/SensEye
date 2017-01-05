//
//  String+AddText.swift
//  MyLocations
//
//  Created by Anton Novoselov on 19/06/16.
//  Copyright © 2016 Anton Novoselov. All rights reserved.
//


extension String {
    
    mutating func addText(text: String?, withSeparator separator: String = "") {
        
        if let text = text {
            if !isEmpty {
                self += separator
            }
            self += text
        }
        
        
    }

    
}


