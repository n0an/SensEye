//
//  User.swift
//  SensEye
//
//  Created by Anton Novoselov on 26/12/2016.
//  Copyright © 2016 Anton Novoselov. All rights reserved.
//

import Foundation
import SwiftyJSON

class User {
    
    // MARK: - PROPERTIES
    var userID: String!
    var firstName: String!
    var lastName: String!
    var imageURL: String!
    
    // MARK: - INITIALIZERS
    init(responseObject: JSON) {
        
        self.userID = String(responseObject["id"].intValue)
        
//        if let userID = responseObject["id"] as? Int {
//            self.userID = String(userID)
//        }
        
        self.firstName = responseObject["first_name"].stringValue
        
//        if let firstName = responseObject["first_name"] as? String {
//            self.firstName = firstName
//        }
        
        self.lastName = responseObject["last_name"].stringValue
        
//        if let lastName = responseObject["last_name"] as? String {
//            self.lastName = lastName
//        }

        
        self.imageURL = responseObject["photo_50"].stringValue

//        if let url50 = responseObject["photo_50"] as? String {
//            self.imageURL = url50
//        }
    }
}
