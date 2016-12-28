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
            
        }
        
        if let firstName = responseObject["first_name"] as? String {
            
            self.firstName = firstName
            
        }
        
        if let lastName = responseObject["last_name"] as? String {
            
            self.lastName = lastName

        }
        
        if let url50 = responseObject["photo_50"] as? String {
            self.imageURL = url50
        }
        
        
        
        
    }
    
}
