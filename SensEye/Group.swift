//
//  Group.swift
//  SensEye
//
//  Created by Anton Novoselov on 26/12/2016.
//  Copyright © 2016 Anton Novoselov. All rights reserved.
//

import Foundation
import SwiftyJSON

class Group {
    
    // MARK: - PROPERTIES
    var groupID: String!
    var groupName: String!
    var screenName: String!
    var imageURL: String!
    
    // MARK: - INITIALIZERS
    init(responseObject: JSON) {
        
        self.groupID = String(responseObject["id"].intValue)
        
        self.groupName = responseObject["name"].stringValue
        
        self.screenName = responseObject["screen_name"].stringValue
        
        self.imageURL = responseObject["photo_50"].stringValue
      
    }
}
