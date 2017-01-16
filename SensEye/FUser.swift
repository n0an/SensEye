//
//  FUser.swift
//  SensEye
//
//  Created by Anton Novoselov on 16/01/2017.
//  Copyright © 2017 Anton Novoselov. All rights reserved.
//

import Foundation
import Firebase

typealias modelCompletion = (Error?) -> Void

class FUser {
    
    // MARK: - PROPERTIES
    var uid: String
    var username: String
    
    var userRef: FIRDatabaseReference
    
    // MARK: - INITIALIZERS
    init(uid: String, username: String, friends: [String]) {
        self.uid =      uid
        self.username = username
        
        userRef = DataService.instance.REF_USERS.child(self.uid)
    }
    
    init(uid: String, dictionary: [String: Any]) {
        self.uid = uid
        self.username = dictionary["username"] as! String
        
        userRef = DataService.instance.REF_USERS.child(self.uid)
    }
    
    
    // MARK: - SAVE METHOD
    func toDictionary() -> [String: Any] {
        return [
            "username": username
        ]
    }
    
    func save(completion: @escaping modelCompletion) {
        userRef.setValue(toDictionary())
        
        completion(nil)
    }
}




// COMPARE METHOD (FOR "CONTAINS" FEATURE) - for checking if array constains current User
extension FUser: Equatable { }
func ==(lhs: FUser, rhs: FUser) -> Bool {
    return lhs.uid == rhs.uid
}
