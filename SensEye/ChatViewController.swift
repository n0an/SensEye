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
    
    var chatUsers: [FRUser] = []
    
    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = chat.withUserName
        
        
        var backButton: UIBarButtonItem
            

        if currentUser.uid == appOwnerUID {
            backButton = UIBarButtonItem(image: UIImage(named: "icon-back"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(actionBackButtonTapped))

        } else {
            backButton = UIBarButtonItem(title: "Logout", style: .done, target: self, action: #selector(logoutButtonTapped))

        }
        
        self.navigationItem.leftBarButtonItem = backButton
        
        
        if self.chatUsers.isEmpty {
            
            self.fetchChatUsers()
        }
        
        self.setupBubbleImages()
        self.setupAvatarImages()
        
        self.observeNewMessages()

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.navigationController?.isNavigationBarHidden = false
    }

    
    
    // MARK: - HELPER METHODS
    func fetchChatUsers() {
        
        for userId in self.chat.userIds {
            
            let ref = FRDataManager.sharedManager.REF_USERS.child(userId)
            
            ref.observeSingleEvent(of: .value, with: { (snapshot) in
                
                let chatUser = FRUser(uid: snapshot.key, dictionary: snapshot.value as! [String: Any])
                
                self.chatUsers.append(chatUser)
                
            })
            
            
        }
        
        
    }
    
    
    
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
    
    // MARK: - AVATAR IMAGES
    func setupAvatarImages() {
        
        // TODO: Download avatars from FIRStorage, and use them in this method
        collectionView.collectionViewLayout.incomingAvatarViewSize = CGSize.zero
        collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSize.zero
        
    }


    // MARK: - ACTIONS
    
    func logoutButtonTapped() {
        
        GeneralHelper.sharedHelper.showLogoutView(onViewController: self) { (success) in
            
            if success == true {
                do {
                    try FIRAuth.auth()?.signOut()
                    
                } catch {
                    self.alertError(error: error as NSError)
                }
            }
            
        }
        
    }
    
    func actionBackButtonTapped() {
        
        self.navigationController?.popViewController(animated: true)
        
    }
    
    
}

// MARK: - JSQMessagesCollectionViewDataSource
extension ChatViewController {
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return jsqMessages.count
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
        return jsqMessages[indexPath.item]
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = super.collectionView(collectionView, cellForItemAt: indexPath) as! JSQMessagesCollectionViewCell
        
        let jsqMessage = jsqMessages[indexPath.item]
        
        if jsqMessage.senderId == self.senderId {
            // OUTGOING MESSAGE WHITE TEXT
            cell.textView.textColor = UIColor.white
        } else {
            // INCOMING MESSAGE BLACK TEXT
            cell.textView.textColor = UIColor.black
        }
        
        return cell
    }
    
    // *** CHOOSING BUBBLE IMAGE FOR OUTGOING IN INCOMING
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
        
        let jsqMessage = jsqMessages[indexPath.item]
        
        if jsqMessage.senderId == self.senderId {
            return self.outgoingBubble
        } else {
            return self.incomingBubble
        }
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource! {
        return nil
    }
    
    
}


// MARK: - SEND MESSAGES
extension ChatViewController {
    
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
        
        let newMessage = FRMessage(senderUID: currentUser.uid, senderDisplayName: currentUser.username, text: text)
        
        newMessage.save()
        
        chat.send(message: newMessage)
        
        JSQSystemSoundPlayer.jsq_playMessageSentSound()
        
        finishSendingMessage()
        
        
    }
    
    
}




























