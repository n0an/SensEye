//
//  WelcomeVC.swift
//  SensEye
//
//  Created by Anton Novoselov on 22/01/2017.
//  Copyright © 2017 Anton Novoselov. All rights reserved.
//

import UIKit
import Firebase

class WelcomeVC: UIViewController {
    
    // MARK: - OUTLETS
    @IBOutlet weak var logoutButton: UIButton!
    @IBOutlet weak var currentUserAvatarImageView: UIImageView!
    
    
    // MARK: - PROPERTIES
    enum Storyboard {
        static let segueShowRecentChats = "showRecentChatsViewController"
        static let segueShowChatVC = "showChatViewController"
        
    }
    
    var currentUser: FRUser!
    
    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        super.viewDidLoad()
        
        FIRAuth.auth()?.addStateDidChangeListener({ (auth, user) in
            
            if let user = user {
                
                FRDataManager.sharedManager.REF_USERS.child(user.uid).observeSingleEvent(of: .value, with: { (snapshot) in
                    
                    if let userDict = snapshot.value as? [String: Any] {
                        
                        FRAuthManager.sharedManager.currentUser = FRUser(uid: user.uid, dictionary: userDict)
                        self.currentUser = FRAuthManager.sharedManager.currentUser
                        
                        print("===NAG===: currentUser = \(FRAuthManager.sharedManager.currentUser.username)")
                        
                        
                        self.goToMessenger()
                        
                        
                    }
                    
                })
                
            } else {
                
                let loginVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
                
                loginVC.hidesBottomBarWhenPushed = false
                self.navigationController?.pushViewController(loginVC, animated: false)
            }
            
        })
        
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.isNavigationBarHidden = true
    }
    
    deinit {
        print("===NAG=== DEINIT WelcomeVC")
    }
    
    
    // MARK: - HELPER METHODS
    
    func postOnLoginNotification() {
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "FRUserDidLoginNotification"), object: nil, userInfo: ["userId" : FIRAuth.auth()!.currentUser!.uid])
        
    }
    
    func goToMessenger() {
        
        self.postOnLoginNotification()
        
        if self.currentUser.uid == appOwnerUID {
            // SUPER ADMIN USER - SEE ALL CHATS
            self.performSegue(withIdentifier: Storyboard.segueShowRecentChats, sender: nil)
            
            
        } else {
            // CUSTOMER USER - GO DIRECTLY TO OWN USER CHAT WITH APPOWNER
            
            let userChatsIdsRef = FRDataManager.sharedManager.REF_USERS.child(currentUser.uid).child("chatIds")
            
            userChatsIdsRef.observeSingleEvent(of: .value, with: { (snapshot) in
                
                if snapshot.exists() {
                    print("snapshot.exists(). GO TO CHAT VIEW CONTROLLER")
                    
                    let chatsDict = snapshot.value as! [String: Any]
                    
                    let chatId = (chatsDict.keys.first)!
                    
                    FRDataManager.sharedManager.REF_CHATS.child(chatId).observeSingleEvent(of: .value, with: { (snapshot) in
                        
                        let chat = FRChat(uid: chatId, dictionary: snapshot.value as! [String: Any])
                        
                        let ref = FRDataManager.sharedManager.REF_USERS.child(appOwnerUID)
                        
                        
                        ref.observeSingleEvent(of: .value, with: { (snapshot) in
                            
                            let chatUser = FRUser(uid: snapshot.key, dictionary: snapshot.value as! [String: Any])
                            
                            
                            let chatUsers: [FRUser] = [self.currentUser, chatUser]
                            
                            
                            self.performSegue(withIdentifier: Storyboard.segueShowChatVC, sender: (chat, chatUsers))
                            
                            
                        })
                        
                        
                    })
                    
                    
                } else {
                    print("snapshot NOT exists(). CREATE NEW CHAT AND GO TO CHAT VIEW CONTROLLER")
                    
                    let userIds = [self.currentUser.uid, appOwnerUID]
                    
                    
                    let newChat = FRChat(userIds: userIds, withUserName: self.currentUser.username, withUserUID: self.currentUser.uid)
                    
                    newChat.userIds = userIds
                    
                    newChat.save()
                    
                    
                    let ref = FRDataManager.sharedManager.REF_USERS.child(appOwnerUID)
                    
                    
                    ref.observeSingleEvent(of: .value, with: { (snapshot) in
                        
                        let chatUser = FRUser(uid: snapshot.key, dictionary: snapshot.value as! [String: Any])
                        
                        
                        let chatUsers: [FRUser] = [self.currentUser, chatUser]
                        
                        for account in chatUsers {
                            account.saveNewChat(newChat)
                        }
                        
                        self.performSegue(withIdentifier: Storyboard.segueShowChatVC, sender: (newChat, chatUsers))
                        
                        
                    })
                }
            })
            
            
            
        }
        
    }
    
    
    func fetchNewChatUser(forUserId userId: String) -> FRUser? {
        
        let ref = FRDataManager.sharedManager.REF_USERS.child(userId)
        
        var result: FRUser?
        
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            
            let chatUser = FRUser(uid: snapshot.key, dictionary: snapshot.value as! [String: Any])
            
            result = chatUser
            
            
            
        })
        
        return result
        
    }
    
    
    
    func fetchMessages() {
        
        if self.currentUser.avatarImage == nil {
            
            self.currentUserAvatarImageView.image = UIImage(named: "icon-defaultAvatar")
            
            self.currentUser.downloadAvatarImage { (image, error) in
                
                if let image = image {
                    
                    self.currentUserAvatarImageView.image = image
                    
                } else if let error = error {
                    self.alertError(error: error as NSError)
                }
                
            }
            
        } else {
            
            self.currentUserAvatarImageView.image = currentUser.avatarImage
            
        }
        
        
    }
    
    
    
    
    // MARK: - ACTIONS
    @IBAction func logoutButtonTapped() {
        
        GeneralHelper.sharedHelper.showLogoutView(onViewController: self) { (success) in
            
            if success == true {
                
                FRAuthManager.sharedManager.logOut(onComplete: { (error) in
                    if let error = error {
                        self.alertError(error: error as NSError)
                    }
                })
                
  
            }
            
        }
        
    }
    
    
    // MARK: - NAVIGATION
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == Storyboard.segueShowChatVC {
            
            let chatVC = segue.destination as! ChatViewController
            
            
            guard let senderTuple = sender as? (FRChat, [FRUser]) else {
                return
            }
            
            let selectedChat = senderTuple.0
            let chatUsers = senderTuple.1
            
            chatVC.chatUsers = chatUsers
            
            
            chatVC.currentUser = currentUser
            
            chatVC.chat = selectedChat
            
            chatVC.senderId = currentUser.uid
            
            chatVC.senderDisplayName = currentUser.username
            
            chatVC.hidesBottomBarWhenPushed = true
            
            
        }
        
        
        
    }
    
    
    
    
    
    
    
    
    
}
















