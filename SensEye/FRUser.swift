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
    var email: String
    var avatarImage: UIImage?
    var avatarDownloadLink: String?
    var pushId: String?
    var userRef: FIRDatabaseReference
    
    // MARK: - INITIALIZERS
    init(uid: String, username: String, email: String, avatarImage: UIImage?, pushId: String?) {
        self.uid            = uid
        self.username       = username
        self.email          = email
        self.avatarImage    = avatarImage
        self.pushId         = pushId
        self.userRef        = FRDataManager.sharedManager.REF_USERS.child(self.uid)
    }
    
    init(uid: String, dictionary: [String: Any]) {
        self.uid        = uid
        self.username   = dictionary["username"] as! String
        self.email      = dictionary["email"] as! String
        self.pushId     = dictionary["pushId"] as? String
        self.userRef    = FRDataManager.sharedManager.REF_USERS.child(self.uid)
    }
    
    // MARK: - SAVE METHOD
    func save(completion: @escaping FRModelCompletion) {
        userRef.setValue(toDictionary())
        
        // save avatar image
        if let avatarImage = self.avatarImage {
            let firImage = FRImage(image: avatarImage)
            firImage.saveAvatarImageToFirebaseStorage(self.uid, completion: { (meta, error) in
                completion(error)
            })
        } else {
            completion(nil)
        }
    }
    
    func toDictionary() -> [String: Any] {
        return [
            "username": username,
            "pushId": pushId ?? "",
            "email": email
        ]
    }
    
    // MARK: - DOWNLOAD AVATAR
    func downloadAvatarImage(completion: @escaping (UIImage?, Error?) -> Void) {
        FRImage.downloadAvatarImageFromFirebaseStorage(self.uid) { (image, error) in
            self.avatarImage = image
            completion(image, error)
        }
    }
}



// MARK: - Equatable
// COMPARE METHOD (FOR "CONTAINS" FEATURE) - for checking if array constains current User
extension FRUser: Equatable { }
func ==(lhs: FRUser, rhs: FRUser) -> Bool {
    return lhs.uid == rhs.uid
}




