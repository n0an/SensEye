//
//  FRUser.swift
//  SensEye
//
//  Created by Anton Novoselov on 16/01/2017.
//  Copyright © 2017 Anton Novoselov. All rights reserved.
//

import Foundation
import Firebase

typealias FRModelCompletion = (Error?) -> Void

class FRUser {
    
    // MARK: - PROPERTIES
    var uid: String
    var username: String
    var avatarImage: UIImage?
    
    var userRef: FIRDatabaseReference
    
    // MARK: - INITIALIZERS
    init(uid: String, username: String) {
        self.uid =      uid
        self.username = username
        
        userRef = FRDataManager.sharedManager.REF_USERS.child(self.uid)
    }
    
    init(uid: String, dictionary: [String: Any]) {
        self.uid = uid
        self.username = dictionary["username"] as! String
        
        userRef = FRDataManager.sharedManager.REF_USERS.child(self.uid)
        
        
    }
    
    
    // MARK: - SAVE METHOD
    func toDictionary() -> [String: Any] {
        return [
            "username": username
        ]
    }
    
    func save(completion: @escaping FRModelCompletion) {
        userRef.setValue(toDictionary())
        
        // save avatar image
        if let avatarImage = avatarImage {
            let firImage = FRImage(image: avatarImage)
            firImage.saveAvatarImageToFirebaseStorage(self.uid, completion: { (meta, error) in
                completion(error)
            })
        }
        
        
//        completion(nil)
    }
}




// COMPARE METHOD (FOR "CONTAINS" FEATURE) - for checking if array constains current User
extension FRUser: Equatable { }
func ==(lhs: FRUser, rhs: FRUser) -> Bool {
    return lhs.uid == rhs.uid
}
