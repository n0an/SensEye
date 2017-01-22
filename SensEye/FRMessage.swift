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
    
    var senderDisplayName: String
    var senderUID: String
    
    var lastUpdate: Double!
    
    var text: String
    
    var messageRef: FIRDatabaseReference
    
    // MARK: - INITIALIZERS
    init(senderUID: String, senderDisplayName: String, text: String) {
        
        self.messageRef = FRDataManager.sharedManager.REF_MESSAGES.childByAutoId()
        
        self.uid = messageRef.key
        
        self.senderDisplayName = senderDisplayName
        self.senderUID = senderUID
        
        self.text = text
        
    }
    
    init(uid: String, dictionary: [String: Any]) {
        
        self.uid = uid
        
        
        self.messageRef = FRDataManager.sharedManager.REF_MESSAGES.child(self.uid)
        
        self.senderDisplayName = dictionary["senderDisplayName"] as! String
        self.senderUID = dictionary["senderUID"] as! String
        
        self.lastUpdate = dictionary["lastUpdate"] as! Double

        self.text = dictionary["text"] as! String
        
        
        
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























