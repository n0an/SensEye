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
    
    var chatUsers: [FRUser] = []
        var initialLoadComplete: Bool = false
    
    var messages = [FRMessage]()
    var messagesLoaded = [FRMessage]()
    
    
    var max = 0
    var min = 0

    var loadCount = 0
    
    
    var jsqMessages = [JSQMessage]()
    
    var outgoingBubble: JSQMessagesBubbleImage!
    var incomingBubble: JSQMessagesBubbleImage!
    
    
    
    
    
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
        self.observeMessageChanged()
        self.obserInitialLoadMessages()
        

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.navigationController?.isNavigationBarHidden = false
    }

    
    
    // MARK: - FIREBASE METHODS
    func fetchChatUsers() {
        
        for userId in self.chat.userIds {
            
            let ref = FRDataManager.sharedManager.REF_USERS.child(userId)
            
            ref.observeSingleEvent(of: .value, with: { (snapshot) in
                
                let chatUser = FRUser(uid: snapshot.key, dictionary: snapshot.value as! [String: Any])
                
                self.chatUsers.append(chatUser)
                
            })
        }
    }
    
    
    // * OBSERVERS
    func observeNewMessages() {
        
        let messagesRef = FRDataManager.sharedManager.REF_MESSAGES.child(self.chat.uid)
        
        messagesRef.observe(.childAdded, with: { (snapshot) in
            
            if snapshot.exists() {
                
                let message = FRMessage(uid: snapshot.key, chatId: self.chat.uid, dictionary: snapshot.value as! [String: Any])

                if self.initialLoadComplete {
                    
                    let incoming = self.insertMessage(message)
                    
                    if incoming {
                        JSQSystemSoundPlayer.jsq_playMessageReceivedAlert()
                    }
                    
                    self.finishReceivingMessage()
                    
                } else {
                    self.messagesLoaded.append(message)
                }
                
                
            }
            
        })
        
        
        
    
        
    }
    
    
    func observeMessageChanged() {
        
        
        let messagesRef = FRDataManager.sharedManager.REF_MESSAGES.child(self.chat.uid)

        messagesRef.observe(.childChanged, with: { (snapshot) in
        
            let message = FRMessage(uid: snapshot.key, chatId: self.chat.uid, dictionary: snapshot.value as! [String: Any])
            
            self.updateMessage(message)
            
        })
        
        
        
    }
    
    func obserInitialLoadMessages() {
        
        let messagesRef = FRDataManager.sharedManager.REF_MESSAGES.child(self.chat.uid)

        messagesRef.observeSingleEvent(of: .value, with: { (snapshot) in
            
            self.insertInitialMessages()
            self.finishReceivingMessage(animated: false)
            self.initialLoadComplete = true
            
            
            
        })
        
  
        
    }
    
    
    
    
    
    // MARK: - HELPER METHODS
    
    // =============================================
    // vvvvvvvvvvvvvvv QUICK CHAT VER vvvvvvvvvvvvv
    // =============================================

    // * Incoming/Outgoing FRMessage checkers
    func incomingMessage(_ message: FRMessage) -> Bool {
        if self.currentUser.uid == message.senderUID {
            return false
        } else {
            return true
        }
    }
    
    func outgoingMessage(_ message: FRMessage) -> Bool {
        return !incomingMessage(message)
    }
    
    
    
    func loadMore(maxNumber: Int, minNumber: Int) {
        
        max = minNumber - 1
        min = max - kNUMBEROFMESSAGES
        
        if min < 0 {
            
            min = 0
        }
        
        for i in (min ... max).reversed() {
            
            let message = self.messagesLoaded[i]
            self.insertNewMessage(message)
            loadCount += 1
        }
        
        self.showLoadEarlierMessagesHeader = (loadCount != messagesLoaded.count)
        
    }
    
    
    // ** INSERT NEW MESSAGE AFTER TAPPING LOAD MORE BUTTON
    func insertNewMessage(_ message: FRMessage) -> Bool {
        
        let incomingMessage = IncomingMessage(collectionView: self.collectionView)
        
        let jsqMessage = incomingMessage.createJSQMessage(fromFRMessage: message)
        
        self.messages.insert(message, at: 0)
        self.jsqMessages.insert(jsqMessage, at: 0)
        
        return self.incomingMessage(message)
        
    }
    
    // ** CAST FRMESSAGE TO JSQMESSAGE. POPULATING JSQMESSAGES ARRAY
    func insertMessage(_ message: FRMessage) -> Bool {
        
        let incomingMessage = IncomingMessage(collectionView: self.collectionView)
        
        
        if self.currentUser.uid == message.senderUID {
            self.chat.updateChatStatus(message)
        }
        
        
        let jsqMessage = incomingMessage.createJSQMessage(fromFRMessage: message)
        
        self.messages.append(message)
        
        self.jsqMessages.append(jsqMessage)
        
        return self.incomingMessage(message)
        
    }
    
    func insertInitialMessages() {
        
        max = messagesLoaded.count - loadCount
        min = max - kNUMBEROFMESSAGES
        
        
        if min < 0 {
            min = 0
        }
        
        for i in min ..< max {
            
            let message = messagesLoaded[i]
            self.insertMessage(message)
            loadCount += 1
        }
        
        self.showLoadEarlierMessagesHeader = (loadCount != messagesLoaded.count)
        
        
    }
    
    
    
    func updateMessage(_ message: FRMessage) {
        
        for index in 0 ..< self.messages.count {
            
            let temp = self.messages[index]
            
            if message.uid == temp.uid {
                
                self.messages[index] = message
                self.collectionView!.reloadData()
            }
        }

        
    }
   

    
    
    
    // ^^^^^^^^^^^^^^^ QUICK CHAT VER ^^^^^^^^^^^^^^^^

    
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

// MARK: - JSQMessages Delegate
// MARK: - SEND MESSAGES
extension ChatViewController {
    
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
        
        let newMessage = FRMessage(chatId: self.chat.uid, senderUID: currentUser.uid, senderDisplayName: currentUser.username, text: text)
        
        newMessage.save()
        
        
        JSQSystemSoundPlayer.jsq_playMessageSentSound()
        
        finishSendingMessage()
        
        chat.send(message: newMessage)
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, header headerView: JSQMessagesLoadEarlierHeaderView!, didTapLoadEarlierMessagesButton sender: UIButton!) {
        
        self.loadMore(maxNumber: max, minNumber: min)
        self.collectionView.reloadData()
        
        
    }
    
    
    
}




























