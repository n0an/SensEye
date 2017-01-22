//
//  FRChat.swift
//  SensEye
//
//  Created by Anton Novoselov on 22/01/2017.
//  Copyright © 2017 Anton Novoselov. All rights reserved.
//

import Foundation
import Firebase


class FRChat {
    
    // MARK: - PROPERTIES
    var uid: String
    var userIds: [String]
    
    var lastMessage: String
    var lastUpdate: Double!
    
    var withUserName: String
    var withUserUID: String
    
    var messageIds: [String]
    var messagesCount: Int
    
    var chatRef: FIRDatabaseReference
    
    // MARK: - INITIALIZERS
    init(userIds: [String], withUserName: String, withUserUID: String) {
        
        self.chatRef = FRDataManager.sharedManager.REF_CHATS.childByAutoId()
        
        self.uid = chatRef.key
        self.userIds = userIds
        
        self.lastMessage = ""
        
        // TODO: - lastUpdate using FIR Server Value
        
        self.withUserName = withUserName
        self.withUserUID = withUserUID
        
        self.messageIds = []
        self.messagesCount = 0
        
    }
    
    init(uid: String, dictionary: [String: Any]) {
        
        self.uid = uid
        
        self.chatRef = FRDataManager.sharedManager.REF_CHATS.child(self.uid)
        
        self.lastMessage = dictionary["lastMessage"] as! String
        self.lastUpdate = dictionary["lastUpdate"] as! Double
        
        self.withUserName = dictionary["withUserName"] as! String
        
        self.withUserUID = dictionary["withUserUID"] as! String
        
        // init users
        
        
//        var users: [FRUser] = []
//        
//        if let usersDict = dictionary["users"] as? [String: Any] {
//            
//            for user in usersDict.values {
//                
//                if let user = user as? [String: Any] {
//                    
//                    let userUid = user.first?.key
//                    
//                    let userRef = FRDataManager.sharedManager.REF_USERS.child(userUid!)
//                    
//                    userRef.observeSingleEvent(of: .value, with: { (snapshot) in
//                        
//                        let userKey = snapshot.key
//                        let userDictionary = snapshot.value
//                        
//                        let user = FRUser(uid: userKey, dictionary: userDictionary as! [String : Any])
//                        
//                        users.append(user)
//                        
//                    })
//                    
//                    
//                    
//                }
//                
//            }
//            
//        }
        
        
        self.userIds = []
        
        
        if let userIdsDict = dictionary["userIds"] as? [String: Any] {
            
            for user in userIdsDict.keys {
                self.userIds.append(user)
            }
            
        }
        
        
        // init messages
        
        self.messageIds = []
        
        if let messageIdsDict = dictionary["messageIds"] as? [String: Any] {
            
            for message in messageIdsDict.keys {
                
                self.messageIds.append(message)
                
            }
            
        }
        
        self.messagesCount = self.messageIds.count
        
    }
    
    
    
    // MARK: - SAVE METHODS
    
    func save() {
        
        self.chatRef.setValue(toDictionary())
        
        // saving usersIds
        let userIdsRef = self.chatRef.child("userIds")
        
        for userId in userIds {
            userIdsRef.child(userId).setValue(true)
        }
        
        // saving messagesIds
        let messageIdsRef = self.chatRef.child("messageIds")
        
        for messageId in messageIds {
            messageIdsRef.child(messageId).setValue(true)
        }
        
    }
    
    func toDictionary() -> [String: Any] {
        
        return [
            "lastMessage": lastMessage,
            "lastUpdate": FIRServerValue.timestamp(),
            "withUserName": withUserName,
            "withUserUID": withUserUID
        
        ]
        
    }
    
    
}


extension FRChat {
    
    // MARK: - DOWNLOAD IMAGE
    
    func downloadWithUserImage(completion: @escaping (UIImage?, Error?) -> Void) {
        
        FRImage.downloadAvatarImageFromFirebaseStorage(self.withUserUID) { (image, error) in
            
            completion(image, error)
            
        }
        
    }
    
    // MARK: - SEND MESSAGE
    // TODO: - ADD SEND MESSAGE HANDLER
    
    func send(message: FRMessage) {
        self.messageIds.append(message.uid)
        
        self.lastMessage = message.text
        
        // Partially saving when sending a message
        self.chatRef.child("lastMessage").setValue(self.lastMessage)
        self.chatRef.child("messageIds").child(message.uid).setValue(true)
        
        // TODO: - update lastUpdate using Firebase server value
    }
    
    
}


// MARK: - Equatable
extension FRChat: Equatable { }
func ==(lhs: FRChat, rhs: FRChat) ->Bool {
    return lhs.uid == rhs.uid
}
























