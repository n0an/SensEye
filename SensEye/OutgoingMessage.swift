//
//  OutgoingMessage.swift
//  SensEye
//
//  Created by Anton Novoselov on 22/01/2017.
//  Copyright © 2017 Anton Novoselov. All rights reserved.
//

import Foundation


class OutgoingMessage {
    
    let ref = FRDataManager.sharedManager.REF_MESSAGES
    
    var message: FRMessage
    
    init(chatId: String, text: String, senderId: String, senderName: String, date: Date) {
        
//        self.message = FRMessage(senderUID: senderId, senderDisplayName: senderName, text: text)
        
        self.message = FRMessage(chatId: chatId, senderUID: senderId, senderDisplayName: senderName, text: text)
        
        
    }
    
    func sendMessage(message: FRMessage, chatId: String) {
        
        
        
        
        
    }
    
    
    
    
}





















