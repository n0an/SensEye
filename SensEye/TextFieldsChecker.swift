//
//  TextFieldsChecker.swift
//  SensEye
//
//  Created by Anton Novoselov on 08/02/2017.
//  Copyright © 2017 Anton Novoselov. All rights reserved.
//

import UIKit

class TextFieldsChecker {
    
    // MARK: - PROPERTIES
    static let sharedChecker = TextFieldsChecker()
    
    // MARK: - handleEmailTextField
    func handleEmailTextField(_ textField: UITextField, inRange range: NSRange, withReplacementString replacementString: String) -> Bool {
        
        var illegalCharactersSet = CharacterSet.init(charactersIn: "?><,\\/|`~\'\"[]{}±#$%^&*()=+")
        
        let currentString = textField.text! as NSString
        
        let newString = currentString.replacingCharacters(in: range, with: replacementString)
        
        if currentString.length == 0 && replacementString == "@" {
            return false
        }
        
        if currentString.contains("@") {
            illegalCharactersSet = CharacterSet.init(charactersIn: "?><,\\/|`~\'\"[]{}±#$%^&*()=+@")
        }
        
        let components = replacementString.components(separatedBy: illegalCharactersSet)
        if components.count > 1 {
            return false
        }
        
        return newString.count <= 40
    }
    
}

