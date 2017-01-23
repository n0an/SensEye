//
//  FRChat.swift
//  SensEye
//
//  Created by Anton Novoselov on 22/01/2017.
//  Copyright © 2017 Anton Novoselov. All rights reserved.
//

import Foundation
import Firebase
import OneSignal


class FRChat {
    
    // MARK: - PROPERTIES
    var uid: String
    var userIds: [String]
    
    var lastMessage: String
    var lastUpdate: Double!
    
    var withUserName: String
    var withUserUID: String
    
    var messagesCount: Int
    
    var chatRef: FIRDatabaseReference
    
    // MARK: - INITIALIZERS
    init(userIds: [String], withUserName: String, withUserUID: String) {
        
        self.chatRef = FRDataManager.sharedManager.REF_CHATS.childByAutoId()
        
        self.uid = chatRef.key
        self.userIds = userIds
        
        self.lastMessage = ""
        
        self.withUserName = withUserName
        self.withUserUID = withUserUID
        
        self.messagesCount = 0
        
    }
    
    init(uid: String, dictionary: [String: Any]) {
        
        self.uid = uid
        
        self.chatRef = FRDataManager.sharedManager.REF_CHATS.child(self.uid)
        
        self.lastMessage = dictionary["lastMessage"] as! String
        self.lastUpdate = dictionary["lastUpdate"] as! Double
        
        self.withUserName = dictionary["withUserName"] as! String
        
        self.withUserUID = dictionary["withUserUID"] as! String
        
        self.messagesCount = dictionary["messagesCount"] as! Int
        
        // init users
        
        self.userIds = []
        
        if let userIdsDict = dictionary["userIds"] as? [String: Any] {
            
            for user in userIdsDict.keys {
                self.userIds.append(user)
            }
            
        }
        
        
    }
    
    
    
    // MARK: - SAVE METHODS
    
    func save() {
        
        self.chatRef.setValue(toDictionary())
        
        // saving usersIds
        let userIdsRef = self.chatRef.child("userIds")
        
        for userId in userIds {
            userIdsRef.child(userId).setValue(true)
        }
 
    }
    
    func toDictionary() -> [String: Any] {
        
        return [
            "lastMessage": lastMessage,
            "lastUpdate": FIRServerValue.timestamp(),
            "withUserName": withUserName,
            "withUserUID": withUserUID,
            "messagesCount": messagesCount
            
        ]
        
    }
    
    
    func updateChatStatus(_ message: FRMessage) {
        
        let value = ["status" : "read"]
        
        // TODO: realize DELIVERED/READ status change
        
        
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
    
    func send(message: FRMessage) {

        self.lastMessage = message.text
        
        // Partially saving when sending a message
        self.chatRef.child("lastMessage").setValue(self.lastMessage)

        self.chatRef.child("lastUpdate").setValue(FIRServerValue.timestamp())
        
        // Incrementing unread messages if current user IS NOT app owner
        
        if FRAuthManager.sharedManager.currentUser.uid != appOwnerUID {
            
            self.messagesCount += 1
        }
        
//        if message.senderUID != FRAuthManager.sharedManager.currentUser.uid {
//            self.messagesCount += 1
//        }
        
        self.chatRef.child("messagesCount").setValue(self.messagesCount)
        
        
    }
    
    
    func clearUnreadMessagesCount() {
        
        
        if FRAuthManager.sharedManager.currentUser.uid == appOwnerUID {
            self.messagesCount = 0
            self.chatRef.child("messagesCount").setValue(0)
        }
        
    }
    
    
}



// MARK: - PUSH NOTIFICATIONS

extension FRChat {
    
    func sendPushNotification(_ chatMembers: [FRUser], messageText: String) {
        
        let currentUser = FRAuthManager.sharedManager.currentUser
        
        var pushIds: [String] = []
        
        for user in chatMembers {
            
            if user.uid == currentUser.uid {
                continue
            }
            
            pushIds.append(user.pushId!)
            
        }
        
        
        
        // TODO: user push ids
        
        OneSignal.postNotification([
            
            "contents": ["en": "\(currentUser.username)\n \(messageText)"],
            "ios_badgeType": "Increase",
            "ios_badgeCount": "1",
            "include_player_ids": pushIds
            ])
        
        
        
    }
    
    
    
    
}



















// MARK: - Equatable
extension FRChat: Equatable { }
func ==(lhs: FRChat, rhs: FRChat) ->Bool {
    return lhs.uid == rhs.uid
}
























