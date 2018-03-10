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
        
//
//        if let groupID = responseObject["id"] as? Int {
//            self.groupID = String(groupID)
//        }
        
        self.groupName = responseObject["name"].stringValue
        
//        if let groupName = responseObject["name"] as? String {
//            self.groupName = groupName
//        }
        
        self.screenName = responseObject["screen_name"].stringValue
        
//        if let screenName = responseObject["screen_name"] as? String {
//            self.screenName = screenName
//        }
        
        self.imageURL = responseObject["photo_50"].stringValue
        
//        if let url50 = responseObject["photo_50"] as? String {
//            self.imageURL = url50
//        }
    }
}
