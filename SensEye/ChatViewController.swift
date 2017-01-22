//
//  ChatViewController.swift
//  SensEye
//
//  Created by Anton Novoselov on 22/01/2017.
//  Copyright © 2017 Anton Novoselov. All rights reserved.
//

import UIKit
import Firebase
import JSQMessagesViewController

class ChatViewController: JSQMessagesViewController {
    
    // MARK: - PROPERTIES
    var chat: FRChat!
    var currentUser: FRUser!
    
    var messagesRef = FRDataManager.sharedManager.REF_MESSAGES
    
    var messages = [FRMessage]()
    
    var jsqMessages = [JSQMessage]()
    
    var outgoingBubble: JSQMessagesBubbleImage!
    var incomingBubble: JSQMessagesBubbleImage!
    
    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = chat.withUserName
        
        self.setupBubbleImages()
        
        self.observeNewMessages()

        
    }

    
    // MARK: - HELPER METHODS
    func observeNewMessages() {
        
        let chatMessageIdsRef = chat.chatRef.child("messageIds")
        
        chatMessageIdsRef.observe(.childAdded, with: { (snapshot) in
            
            let messageId = snapshot.key
            
            FRDataManager.sharedManager.REF_MESSAGES.child(messageId).observe(.value, with: { (snapshot) in
                
                let message = FRMessage(uid: messageId, dictionary: snapshot.value as! [String: Any])
                
                self.messages.append(message)
                
                self.addMessages(message)
                
                self.finishReceivingMessage()
            })
        })
    }
    
    func addMessages(_ message: FRMessage) {
        
        let jsqMessage = JSQMessage(senderId: message.senderUID, displayName: message.senderDisplayName, text: message.text)
        // TODO: - Check this method - look at Duc source, and in QuickChat
        
        self.jsqMessages.append(jsqMessage!)
        
    }
    
    func setupBubbleImages() {
        
        let factory = JSQMessagesBubbleImageFactory()
        
        self.outgoingBubble = factory?.outgoingMessagesBubbleImage(with: UIColor.jsq_messageBubbleBlue())
        self.incomingBubble = factory?.incomingMessagesBubbleImage(with: UIColor.jsq_messageBubbleLightGray())
        
    }
    
    


    
    
}



































