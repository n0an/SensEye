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
    
    var avatarDownloadLink: String?
    
    var userRef: FIRDatabaseReference
    
    // MARK: - INITIALIZERS
    init(uid: String, username: String, avatarImage: UIImage?) {
        self.uid =      uid
        self.username = username
        
        self.avatarImage = avatarImage
        
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
        if let avatarImage = self.avatarImage {
            
            let firImage = FRImage(image: avatarImage)
            
            firImage.saveAvatarImageToFirebaseStorage(self.uid, completion: { (meta, error) in
                
                
                // TODO: - delete if not needed to set downloadLink to Firebase Database
//                let downloadURLString = meta?.downloadURL()?.absoluteString
//                
//                if let urlString = downloadURLString {
//                    self.avatarDownloadLink = urlString
//                }
                
                completion(error)
            })
        } else {
            completion(nil)
        }
        
        
    }
    
    
    
    func downloadAvatarImage(completion: @escaping (UIImage?, Error?) -> Void) {
        
        FRImage.downloadAvatarImageFromFirebaseStorage(self.uid) { (image, error) in
            
            self.avatarImage = image
            
            completion(image, error)
            
        }
        
    }
    
    
    
    
    
    
}




// COMPARE METHOD (FOR "CONTAINS" FEATURE) - for checking if array constains current User
extension FRUser: Equatable { }
func ==(lhs: FRUser, rhs: FRUser) -> Bool {
    return lhs.uid == rhs.uid
}


















