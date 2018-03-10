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
    var lastMessage: String
    var lastUpdate: Double!
    var withUserName: String
    var withUserUID: String
    var messagesCount: Int
    var chatRef: DatabaseReference
    
    // MARK: - INITIALIZERS
    init(withUserName: String, withUserUID: String) {
        self.uid            = withUserUID
        self.lastMessage    = ""
        self.withUserName   = withUserName
        self.withUserUID    = withUserUID
        self.messagesCount  = 0
        self.chatRef        = FRDataManager.sharedManager.REF_CHATS.child(self.uid)
    }
    
    init(uid: String, dictionary: [String: Any]) {
        self.uid            = uid
        self.lastMessage    = dictionary["lastMessage"] as! String
        self.lastUpdate     = dictionary["lastUpdate"] as! Double
        self.withUserName   = dictionary["withUserName"] as! String
        self.withUserUID    = dictionary["withUserUID"] as! String
        self.messagesCount  = dictionary["messagesCount"] as! Int
        self.chatRef = FRDataManager.sharedManager.REF_CHATS.child(self.uid)
    }
    
    // MARK: - SAVE METHODS
    func save() {
        self.chatRef.setValue(toDictionary())
    }
    
    func toDictionary() -> [String: Any] {
        return [
            "lastMessage": lastMessage,
            "lastUpdate": ServerValue.timestamp(),
            "withUserName": withUserName,
            "withUserUID": withUserUID,
            "messagesCount": messagesCount
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
    func send(message: FRMessage) {
        self.lastMessage = message.text
        
        // Partially saving when sending a message
        self.chatRef.child("lastMessage").setValue(self.lastMessage)
        self.chatRef.child("lastUpdate").setValue(ServerValue.timestamp())
        
        // Incrementing unread messages if current user IS NOT app owner
        if FRAuthManager.sharedManager.currentUser.email != GeneralHelper.sharedHelper.appOwnerEmail {
            self.messagesCount += 1
        }
        
        self.chatRef.child("messagesCount").setValue(self.messagesCount)
    }
    
    func clearUnreadMessagesCount() {
        if FRAuthManager.sharedManager.currentUser.email == GeneralHelper.sharedHelper.appOwnerEmail {
            self.messagesCount = 0
            self.chatRef.child("messagesCount").setValue(0)
        }
    }
}

extension FRChat {
    
    // MARK: - PUSH NOTIFICATIONS
    func sendPushNotification(_ messageText: String) {
        
        let currentUser = FRAuthManager.sharedManager.currentUser
        
        var recipientUid: String
        
        if currentUser.email == GeneralHelper.sharedHelper.appOwnerEmail {
            recipientUid = self.withUserUID
            
            self.fetchChatUsers(forUids: [recipientUid]) { (pushIds) in
                OneSignal.postNotification([
                    "contents": ["en": "\(currentUser.username)\n\(messageText)"],
                    "ios_badgeType": "Increase",
                    "ios_badgeCount": "1",
                    "include_player_ids": pushIds
                    ])
            }
            
        } else {
            self.sendPushToAppOwner(currentUser: currentUser, messageText: messageText)
        }
    }
    
    func sendPushToAppOwner(currentUser: FRUser, messageText: String) {
        
        let ref = FRDataManager.sharedManager.REF_USERS
        
        ref.queryOrdered(byChild: "email").queryEqual(toValue: GeneralHelper.sharedHelper.appOwnerEmail).observeSingleEvent(of: .value, with: { (snapshot) in
            
            if let snapshot = snapshot.children.allObjects as? [DataSnapshot] {
                
                if let snap = snapshot.first {
                    
                    let chatUser = FRUser(uid: snap.key, dictionary: snap.value as! [String: Any])
                    
                    OneSignal.postNotification([
                        
                        "contents": ["en": "\(currentUser.username)\n\(messageText)"],
                        "ios_badgeType": "Increase",
                        "ios_badgeCount": "1",
                        "include_player_ids": [chatUser.pushId]
                        ])
                }
            }
        })
    }
    
    func fetchChatUsers(forUids userUids: [String], result: @escaping ([String]) -> Void) {
        
        var count = 0
        var pushIds: [String] = []
        
        for userId in userUids {
            
            let ref = FRDataManager.sharedManager.REF_USERS.child(userId)
            
            ref.observeSingleEvent(of: .value, with: { (snapshot) in
                let chatUser = FRUser(uid: snapshot.key, dictionary: snapshot.value as! [String: Any])
                
                pushIds.append(chatUser.pushId!)
                count += 1
                
                if userUids.count == count {
                    result(pushIds)
                }
            })
        }
    }
}

// MARK: - Equatable
extension FRChat: Equatable {
    static func ==(lhs: FRChat, rhs: FRChat) ->Bool {
        return lhs.uid == rhs.uid
    }
}
