//
//  Group.swift
//  SensEye
//
//  Created by Anton Novoselov on 26/12/2016.
//  Copyright © 2016 Anton Novoselov. All rights reserved.
//

import Foundation


class Group {
    
    var groupID: String!
    
    var groupName: String!
    var screenName: String!
    var imageURL: String!
    
    
    init(responseObject: [String: Any]) {
        
        if let groupID = responseObject["id"] as? Int {
            
            self.groupID = String(groupID)
            
            print("===NAG=== self.groupID = \(self.groupID!)")
        }
        
        if let groupName = responseObject["name"] as? String {
            
            self.groupName = groupName
            
            print("===NAG=== self.groupName = \(self.groupName)")
            
        }
        
        if let screenName = responseObject["screen_name"] as? String {
            
            self.screenName = screenName
            
            print("===NAG=== self.screenName = \(self.screenName!)")
            
        }
        
        if let url50 = responseObject["photo_50"] as? String {
            self.imageURL = url50
        }
        
        
        
        
    }
    
}
