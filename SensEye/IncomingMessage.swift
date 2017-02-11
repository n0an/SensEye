//
//  IncomingMessage.swift
//  SensEye
//
//  Created by Anton Novoselov on 22/01/2017.
//  Copyright © 2017 Anton Novoselov. All rights reserved.
//

import Foundation
import JSQMessagesViewController

public class IncomingMessage {

    // MARK: - PROPERTIES
    var collectionView: JSQMessagesCollectionView
    
    // MARK: - INITIALIZERS
    init(collectionView: JSQMessagesCollectionView) {
        self.collectionView = collectionView
    }
    
    // MARK: - HELPER METHODS
    func createJSQMessage(fromFRMessage frMessage: FRMessage) -> JSQMessage {
        let name = frMessage.senderDisplayName
        let userId = frMessage.senderUID
        let timeInterval = frMessage.lastUpdate / 1000
        let date = Date(timeIntervalSince1970: timeInterval)
        
        return JSQMessage(senderId: userId, senderDisplayName: name, date: date, text: frMessage.text)
    }
}

