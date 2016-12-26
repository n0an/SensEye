//
//  User.swift
//  SensEye
//
//  Created by Anton Novoselov on 26/12/2016.
//  Copyright © 2016 Anton Novoselov. All rights reserved.
//

import Foundation

class User {
    
    var userID: String!
    
    var firstName: String!
    var lastName: String!
    var imageURL: String!
    
    
    init(responseObject: [String: Any]) {
        
        if let userID = responseObject["id"] as? Int {
            
            self.userID = String(userID)
            
            print("===NAG=== self.userID = \(self.userID!)")
        }
        
        if let firstName = responseObject["first_name"] as? String {
            
            self.firstName = firstName
            
            print("===NAG=== self.firstName = \(self.firstName!)")
            
        }
        
        if let lastName = responseObject["last_name"] as? String {
            
            self.lastName = lastName
            
            print("===NAG=== self.lastName = \(self.lastName!)")
            
        }
        
        if let url50 = responseObject["photo_50"] as? String {
            self.imageURL = url50
        }
        
        
        
        
    }
    
}
