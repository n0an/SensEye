//
//  LoginViewController.swift
//  SensEye
//
//  Created by Anton Novoselov on 16/01/2017.
//  Copyright © 2017 Anton Novoselov. All rights reserved.
//

import UIKit
import Spring
import Firebase

import GoogleSignIn

import SwiftSpinner

import SwiftKeychainWrapper

class LoginViewController: UIViewController, GIDSignInUIDelegate {
    
    // MARK: - OUTLETS
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: DesignableButton!

    // MARK: - PROPERTIES
    enum Storyboard {
        static let segueShowRecentChats = "showRecentChatsViewController"
        static let segueShowChatVC = "showChatViewController"
        
    }
    
    
    var currentUser: FRUser!
    
    
    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        FIRAuth.auth()?.addStateDidChangeListener({ (auth, user) in
            
            if let user = user {
                
                if self.currentUser != nil {
                    return
                }
                
                SwiftSpinner.show("Entering chat").addTapHandler({ 
                    SwiftSpinner.hide()
                })
                
                
                // ** Checking if there's CurrentUser in Keychain
                if let userDict = KeychainWrapper.standard.object(forKey: KEY_CHAT_USER) as? [String: Any] {
                    
                    print("saved chat user = \(userDict)")
                    
                    let uid = userDict["uid"] as! String
                    
                    FRAuthManager.sharedManager.currentUser = FRUser(uid: uid, dictionary: userDict)
                    self.currentUser = FRAuthManager.sharedManager.currentUser
                    
                    print("===NAG===: KeyChain currentUser = \(FRAuthManager.sharedManager.currentUser.username)")
                    
                    DispatchQueue.main.async {
                        
                        self.goToMessenger()
                    }
                    
                    
                } else {
                    // ** Get user from Firebase, if not found in Keychain
                    FRDataManager.sharedManager.REF_USERS.child(user.uid).observeSingleEvent(of: .value, with: { (snapshot) in
                        
                        if let userDict = snapshot.value as? [String: Any] {
                            
                            FRAuthManager.sharedManager.currentUser = FRUser(uid: user.uid, dictionary: userDict)
                            self.currentUser = FRAuthManager.sharedManager.currentUser
                            
                            let userDictionary = [
                                        "uid": self.currentUser.uid,
                                        "username": self.currentUser.username,
                                        "pushId": self.currentUser.pushId!
                            ]
                            
                            
                            KeychainWrapper.standard.set(userDictionary as NSDictionary, forKey: KEY_CHAT_USER)
                            
                            print("===NAG===: currentUser = \(FRAuthManager.sharedManager.currentUser.username)")
                            
                            DispatchQueue.main.async {
                                
                                self.goToMessenger()
                            }
                            
                        }
                        
                    })
                }
                
                
                
                
            } else {
     
                self.currentUser = nil
            }
            
        })


        
        emailTextField.delegate = self
        passwordTextField.delegate = self
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(resignKeyboard))
        self.view.addGestureRecognizer(tapGesture)
        
        // Google Login
        GIDSignIn.sharedInstance().uiDelegate = self

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
//        emailTextField.becomeFirstResponder()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

    }
    
    deinit {
        print("===NAG=== DEINIT LoginViewController")
    }
    
    
    // MARK: - HELPER METHODS
    
    
    
    func goToMessenger() {
        
        // Configure OneSignal pushId before goToChat
        FRAuthManager.sharedManager.handleOneSignalOnUserLogin()
        
        
        if self.currentUser.uid == GeneralHelper.sharedHelper.appOwnerUID {
            // SUPER ADMIN USER - SEE ALL CHATS
            self.performSegue(withIdentifier: Storyboard.segueShowRecentChats, sender: nil)
            
            
        } else {
            // CUSTOMER USER - GO DIRECTLY TO OWN USER CHAT WITH APPOWNER
            
            
            customerChatVarQueryEqual1()
            
            
        }
        
    }
    
    
    
    func customerChatOld() {
        
        
        let userChatsIdsRef = FRDataManager.sharedManager.REF_USERS.child(currentUser.uid).child("chatIds")
        
        userChatsIdsRef.observeSingleEvent(of: .value, with: { (snapshot) in
            
            if snapshot.exists() {
                print("snapshot.exists(). GO TO CHAT VIEW CONTROLLER")
                
                let chatsDict = snapshot.value as! [String: Any]
                
                let chatId = (chatsDict.keys.first)!
                
                FRDataManager.sharedManager.REF_CHATS.child(chatId).observeSingleEvent(of: .value, with: { (snapshot) in
                    
                    let chat = FRChat(uid: chatId, dictionary: snapshot.value as! [String: Any])
                    
                    let ref = FRDataManager.sharedManager.REF_USERS.child(GeneralHelper.sharedHelper.appOwnerUID)
                    
                    
                    ref.observeSingleEvent(of: .value, with: { (snapshot) in
                        
                        let chatUser = FRUser(uid: snapshot.key, dictionary: snapshot.value as! [String: Any])
                        
                        
                        let chatUsers: [FRUser] = [self.currentUser, chatUser]
                        
                        
                        self.performSegue(withIdentifier: Storyboard.segueShowChatVC, sender: (chat, chatUsers))
                        
                        
                    })
                    
                    
                })
                
                
            } else {
                print("snapshot NOT exists(). CREATE NEW CHAT AND GO TO CHAT VIEW CONTROLLER")
                
                let userIds = [self.currentUser.uid, GeneralHelper.sharedHelper.appOwnerUID]
                
                
                let newChat = FRChat(userIds: userIds, withUserName: self.currentUser.username, withUserUID: self.currentUser.uid)
                
                newChat.userIds = userIds
                
                newChat.save()
                
                
                let refAppOwner = FRDataManager.sharedManager.REF_USERS.child(GeneralHelper.sharedHelper.appOwnerUID)
                
                
                refAppOwner.observeSingleEvent(of: .value, with: { (snapshot) in
                    
                    let appOwnerUser = FRUser(uid: snapshot.key, dictionary: snapshot.value as! [String: Any])
                    
                    
                    let chatUsers: [FRUser] = [self.currentUser, appOwnerUser]
                    
                    
                    for account in chatUsers {
                        account.saveNewChat(newChat)
                    }
                    
                    // Sending the first greeting message from appOwner "Hello, how can I help you?"
                    let greetingMessage = FRMessage(chatId: newChat.uid, senderUID: appOwnerUser.uid, senderDisplayName: appOwnerUser.username, text: "Здравствуйте, я могу Вам чем-то помочь?")
                    
                    greetingMessage.save()
                    
                    newChat.send(message: greetingMessage)
                    
                    self.performSegue(withIdentifier: Storyboard.segueShowChatVC, sender: (newChat, chatUsers))
                    
                })
            }
        })
        

    }
    
    
    
    
    func customerChatVarQueryEqual1() {
        
        FRDataManager.sharedManager.REF_CHATS.child(currentUser.uid).observeSingleEvent(of: .value, with: { (snapshot) in
            print("snapshot.exists(). GO TO CHAT VIEW CONTROLLER")

            if snapshot.exists() {
                
                let chat = FRChat(uid: snapshot.key, dictionary: snapshot.value as! [String: Any])
                
                self.performSegue(withIdentifier: Storyboard.segueShowChatVC, sender: chat)
                
                
//                let ref = FRDataManager.sharedManager.REF_USERS.child(GeneralHelper.sharedHelper.appOwnerUID)
//                
//                
//                
//                
//                ref.observeSingleEvent(of: .value, with: { (snapshot) in
//                    
//                    let chatUser = FRUser(uid: snapshot.key, dictionary: snapshot.value as! [String: Any])
//                    
//                    
//                    let chatUsers: [FRUser] = [self.currentUser, chatUser]
//                    
//                    
//                    self.performSegue(withIdentifier: Storyboard.segueShowChatVC, sender: (chat, chatUsers))
//                    
//                    
//                })
                
                
                
                
            } else {
                
                print("snapshot NOT exists(). CREATE NEW CHAT AND GO TO CHAT VIEW CONTROLLER")
                
                let userIds = [self.currentUser.uid, GeneralHelper.sharedHelper.appOwnerUID]
                
                
                let newChat = FRChat(userIds: userIds, withUserName: self.currentUser.username, withUserUID: self.currentUser.uid)
                
                newChat.userIds = userIds
                
                newChat.save()
                
                
                let greetingMessage = FRMessage(chatId: newChat.uid, senderUID: GeneralHelper.sharedHelper.appOwnerUID, senderDisplayName: "Elena Senseye", text: "Здравствуйте, я могу Вам чем-то помочь?")
                
                greetingMessage.save()
                
                newChat.send(message: greetingMessage)
                
                self.performSegue(withIdentifier: Storyboard.segueShowChatVC, sender: newChat)
                
                
                
                
//                let refAppOwner = FRDataManager.sharedManager.REF_USERS.child(GeneralHelper.sharedHelper.appOwnerUID)
//                
//                
//                refAppOwner.observeSingleEvent(of: .value, with: { (snapshot) in
//                    
//                    let appOwnerUser = FRUser(uid: snapshot.key, dictionary: snapshot.value as! [String: Any])
//                    
//                    
//                    let chatUsers: [FRUser] = [self.currentUser, appOwnerUser]
//                    
//                    
////                    for account in chatUsers {
////                        account.saveNewChat(newChat)
////                    }
//                    
//                    // Sending the first greeting message from appOwner "Hello, how can I help you?"
//                    let greetingMessage = FRMessage(chatId: newChat.uid, senderUID: appOwnerUser.uid, senderDisplayName: appOwnerUser.username, text: "Здравствуйте, я могу Вам чем-то помочь?")
//                    
//                    greetingMessage.save()
//                    
//                    newChat.send(message: greetingMessage)
//                    
//                    self.performSegue(withIdentifier: Storyboard.segueShowChatVC, sender: (newChat, chatUsers))
//                    
//                })

                
            }
            
            
            
        })
        
        
        
        

        
    }
    
    
    
    func customerChatVarQueryEqual() {
        let chatsRef = FRDataManager.sharedManager.REF_CHATS
        
        chatsRef.queryOrdered(byChild: "withUserUID").queryEqual(toValue: currentUser.uid).observeSingleEvent(of: .value, with: { (snapshot) in
            
            if let snapshot = snapshot.children.allObjects as? [FIRDataSnapshot] {
                
                if snapshot.count > 0 {
                    print("snapshot.exists(). GO TO CHAT VIEW CONTROLLER")
                    for snap in snapshot {
                        
                        if let chatDict = snap.value as? [String: Any] {
                            
                            let key = snap.key
                            
                            let chat = FRChat(uid: key, dictionary: chatDict)
                            
                            
                            let ref = FRDataManager.sharedManager.REF_USERS.child(GeneralHelper.sharedHelper.appOwnerUID)
                            
                            
                            ref.observeSingleEvent(of: .value, with: { (snapshot) in
                                
                                let chatUser = FRUser(uid: snapshot.key, dictionary: snapshot.value as! [String: Any])
                                
                                
                                let chatUsers: [FRUser] = [self.currentUser, chatUser]
                                
                                
                                self.performSegue(withIdentifier: Storyboard.segueShowChatVC, sender: (chat, chatUsers))
                                
                                
                            })
                            
                            
                        }
                        
                        
                    }
                    
                    
                } else {
                    print("snapshot NOT exists(). CREATE NEW CHAT AND GO TO CHAT VIEW CONTROLLER")
                    
                    let userIds = [self.currentUser.uid, GeneralHelper.sharedHelper.appOwnerUID]
                    
                    
                    let newChat = FRChat(userIds: userIds, withUserName: self.currentUser.username, withUserUID: self.currentUser.uid)
                    
                    newChat.userIds = userIds
                    
                    newChat.save()
                    
                    
                    let refAppOwner = FRDataManager.sharedManager.REF_USERS.child(GeneralHelper.sharedHelper.appOwnerUID)
                    
                    
                    refAppOwner.observeSingleEvent(of: .value, with: { (snapshot) in
                        
                        let appOwnerUser = FRUser(uid: snapshot.key, dictionary: snapshot.value as! [String: Any])
                        
                        
                        let chatUsers: [FRUser] = [self.currentUser, appOwnerUser]
                        
                        
                        for account in chatUsers {
                            account.saveNewChat(newChat)
                        }
                        
                        // Sending the first greeting message from appOwner "Hello, how can I help you?"
                        let greetingMessage = FRMessage(chatId: newChat.uid, senderUID: appOwnerUser.uid, senderDisplayName: appOwnerUser.username, text: "Здравствуйте, я могу Вам чем-то помочь?")
                        
                        greetingMessage.save()
                        
                        newChat.send(message: greetingMessage)
                        
                        self.performSegue(withIdentifier: Storyboard.segueShowChatVC, sender: (newChat, chatUsers))
                        
                    })
 
                }
                
                
                
                
            }
            
            
            
            
        })

    }
    
    
    
    
//    func goToChatVC() {
//
//        let _ = self.navigationController?.popViewController(animated: false)
//
//
//    }
    
    
    func resignKeyboard() {
        self.view.endEditing(true)
    }

    
    
    // MARK: - ACTIONS
    
    // - Facebook Login
    @IBAction func actionLoginFacebookTapped(_ sender: Any) {
        
        // Dismiss keyboard
        self.view.endEditing(true)
        
        SwiftSpinner.show("Logging in").addTapHandler ({
            SwiftSpinner.hide()
        })
        
        FRAuthManager.sharedManager.loginWithFacebook(viewController: self) { (errorString) in
            
            if let errorString = errorString {
                SwiftSpinner.hide()
                self.alert(title: "Error", message: errorString)
                return
                
            } else {
//                DispatchQueue.main.async {
//                    SwiftSpinner.hide()
//                    self.goToChatVC()
//                }
            }
            
            
        }
        
        
    }
    
    
    // - Google Login
    @IBAction func actionLoginGoogleTapped(_ sender: Any) {
        // Dismiss keyboard
        self.view.endEditing(true)
        
        GIDSignIn.sharedInstance().signIn()
        
        
        
    }
    
    
    // - Email/Password Login
    @IBAction func actionLoginButtonTapped(_ sender: Any) {
        
        guard let email = emailTextField.text, email != "",
            let password = passwordTextField.text, password != "" else {
            self.alert(title: "Error", message: "Enter your email and password")
            return
        }
        
        // Dismiss keyboard
        self.view.endEditing(true)
        
        SwiftSpinner.show("Logging in").addTapHandler ({
            SwiftSpinner.hide()
        })
        
        FRAuthManager.sharedManager.loginToFireBase(withEmail: email, password: password, onComplete: { (errMsg, data) in
            
            guard errMsg == nil else {
                SwiftSpinner.hide()
                self.alert(title: "Error", message: errMsg!)
                return
            }
            
//            DispatchQueue.main.async {
//                SwiftSpinner.hide()
//                self.goToChatVC()
//            }
        })
        
    }
    
    
    @IBAction func unwindToLoginVC(segue: UIStoryboardSegue) {
        
    }
    
    
    // MARK: - NAVIGATION
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        SwiftSpinner.hide()
        
        if segue.identifier == Storyboard.segueShowChatVC {
            
            let chatVC = segue.destination as! ChatViewController
            
            
//            guard let senderTuple = sender as? (FRChat, [FRUser]) else {
//                return
//            }
//            
//            let selectedChat = senderTuple.0
//            let chatUsers = senderTuple.1
            
            let selectedChat = sender as! FRChat

            
//            chatVC.chatUsers = chatUsers
            
            
            chatVC.currentUser = currentUser
            
            chatVC.chat = selectedChat
            
            chatVC.senderId = currentUser.uid
            
            chatVC.senderDisplayName = currentUser.username
            
            chatVC.hidesBottomBarWhenPushed = true
            
            
        }
        
        
        
    }


}




extension LoginViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField == emailTextField {
            passwordTextField.becomeFirstResponder()
        } else if textField == passwordTextField {
            passwordTextField.resignFirstResponder()
            self.actionLoginButtonTapped(self)
        }
        
        return true
        
        
    }
}




























