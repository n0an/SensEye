//
//  FRMessage.swift
//  SensEye
//
//  Created by Anton Novoselov on 22/01/2017.
//  Copyright © 2017 Anton Novoselov. All rights reserved.
//

import Foundation
import Firebase


class FRMessage {
    
    // MARK: - PROPERTIES
    var uid: String
    var chatId: String
    var senderDisplayName: String
    var senderUID: String
    var lastUpdate: Double!
    var text: String
    var messageRef: FIRDatabaseReference
    
    // MARK: - INITIALIZERS
    init(chatId: String, senderUID: String, senderDisplayName: String, text: String) {
        self.messageRef         = FRDataManager.sharedManager.REF_MESSAGES.child(chatId).childByAutoId()
        self.uid                = messageRef.key
        self.chatId             = chatId
        self.senderDisplayName  = senderDisplayName
        self.senderUID          = senderUID
        self.text               = text
    }
    
    init(uid: String, chatId: String, dictionary: [String: Any]) {
        self.uid                = uid
        self.chatId             = chatId
        self.senderDisplayName  = dictionary["senderDisplayName"] as! String
        self.senderUID          = dictionary["senderUID"] as! String
        self.lastUpdate         = dictionary["lastUpdate"] as! Double
        self.text               = dictionary["text"] as! String
        self.messageRef         = FRDataManager.sharedManager.REF_MESSAGES.child(chatId).child(self.uid)
    }
    
    // MARK: - SAVE METHODS
    func save() {
        self.messageRef.setValue(toDictionary())
    }
    
    func toDictionary() -> [String: Any] {
        return [
            "senderDisplayName"     :   senderDisplayName,
            "senderUID"             :   senderUID,
            "lastUpdate"            :   FIRServerValue.timestamp(),
            "text"                  :   text
        ]
    }
}


// MARK: - Equatable
extension FRMessage: Equatable { }
func ==(lhs: FRMessage, rhs: FRMessage) ->Bool {
    return lhs.uid == rhs.uid
}






