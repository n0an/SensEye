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
        
        self.firstName = responseObject["first_name"].stringValue
        
        self.lastName = responseObject["last_name"].stringValue
        
        self.imageURL = responseObject["photo_50"].stringValue
    }
}
