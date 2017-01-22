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
                
                self.navigationController?.pushViewController(loginVC, animated: false)
            }
            
        })

        
    }

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.isNavigationBarHidden = true
    }
    
    // MARK: - HELPER METHODS
    
    func goToMessenger() {
        
        if self.currentUser.uid == appOwnerUID {
            // SUPER ADMIN USER - SEE ALL CHATS
            self.performSegue(withIdentifier: Storyboard.segueShowRecentChats, sender: nil)
            
            
        } else {
            // CUSTOMER USER - GO DIRECTLY TO OWN CHAT
            
            let userChatsIdsRef = FRDataManager.sharedManager.REF_USERS.child(currentUser.uid).child("chatIds")
            
            
//            userChatsIdsRef.observe(.value, with: { (snapshot) in
//                print("observe")
//
//            })
            
            
            userChatsIdsRef.observeSingleEvent(of: .value, with: { (snapshot) in
                
                if snapshot.exists() {
                    print("snapshot.exists(). GO TO CHAT VIEW CONTROLLER")
                    
                    let chatsDict = snapshot.value as! [String: Any]
                    
                    let chatId = (chatsDict.keys.first)!
                    
                    FRDataManager.sharedManager.REF_CHATS.child(chatId).observeSingleEvent(of: .value, with: { (snapshot) in
                        
                        let chat = FRChat(uid: chatId, dictionary: snapshot.value as! [String: Any])
                        
                        self.performSegue(withIdentifier: Storyboard.segueShowChatVC, sender: chat)
                        
                        
                    })
                    
                    
                } else {
                    print("snapshot NOT exists(). CREATE NEW CHAT AND GO TO CHAT VIEW CONTROLLER")
                    
                    let userIds = [self.currentUser.uid, appOwnerUID]
                    
                    
                    let newChat = FRChat(userIds: userIds, withUserName: self.currentUser.username, withUserUID: self.currentUser.uid)
                    
                    newChat.userIds = userIds
                    
//                    newChat.save()
//                    
//                    let chatUsers = self.fetchNewChatUsers(forUserIds: userIds)
//                    
//                    for account in chatUsers {
//                        account.saveNewChat(newChat)
//                    }
                    
                    self.performSegue(withIdentifier: Storyboard.segueShowChatVC, sender: newChat)
                    
                }
            })
            
            
            
            
            
            
            
            
//            userChatsIdsRef.observe(.childAdded, with: { (snapshot) in
//                
//                let chatId = snapshot.key
//                
//                FRDataManager.sharedManager.REF_CHATS.child(chatId).observeSingleEvent(of: .value, with: { (snapshot) in
//                    
//                    let chat = FRChat(uid: chatId, dictionary: snapshot.value as! [String: Any])
//                    
//                    self.performSegue(withIdentifier: Storyboard.segueShowChatVC, sender: chat)
//
//                    
//                })
//                
//                
//            })
            
            
        }
        
    }
    
    
    func fetchNewChatUsers(forUserIds userIds: [String]) -> [FRUser] {
        
        var fetchedUsersArray = [FRUser]()
        
        for userId in userIds {
            
            let ref = FRDataManager.sharedManager.REF_USERS.child(userId)
            
            ref.observeSingleEvent(of: .value, with: { (snapshot) in
                
                let chatUser = FRUser(uid: snapshot.key, dictionary: snapshot.value as! [String: Any])
                
                fetchedUsersArray.append(chatUser)
                
            })
            
            
        }
        
        return fetchedUsersArray
        
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
                do {
                    try FIRAuth.auth()?.signOut()
                    
                } catch {
                    self.alertError(error: error as NSError)
                }
            }
            
        }
        
    }
    
    
    // MARK: - NAVIGATION
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == Storyboard.segueShowChatVC {
            
            let chatVC = segue.destination as! ChatViewController
            
            let selectedChat = sender as! FRChat
            
            chatVC.currentUser = currentUser
            
            chatVC.chat = selectedChat
            
            chatVC.senderId = currentUser.uid
            
            chatVC.senderDisplayName = currentUser.username
            
            chatVC.hidesBottomBarWhenPushed = true
            
            
        }
        
        
        
    }
    
    
    
    
    
    
    

    
}
















