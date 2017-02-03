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
        
        //        forceLogout()
        
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
                        
                        print("===NAG=== GO TO CHAT FROM addStateDidChangeListener")
                        
                        
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
                                "pushId": self.currentUser.pushId!,
                                "email": self.currentUser.email
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
        
        if self.currentUser != nil {
            return
        }
        
        if let userDict = KeychainWrapper.standard.object(forKey: KEY_CHAT_USER) as? [String: Any] {
            
            print("saved chat user = \(userDict)")
            
            let uid = userDict["uid"] as! String
            
            FRAuthManager.sharedManager.currentUser = FRUser(uid: uid, dictionary: userDict)
            self.currentUser = FRAuthManager.sharedManager.currentUser
            
            print("===NAG===: KeyChain currentUser = \(FRAuthManager.sharedManager.currentUser.username)")
            
            DispatchQueue.main.async {
                
                print("===NAG=== GO TO CHAT FROM viewDidAppear")
                
                self.goToMessenger()
            }
        }
    }
    
    
    
    deinit {
        print("===NAG=== DEINIT LoginViewController")
    }
    
    
    // MARK: - HELPER METHODS
    
    func forceLogout() {
        try! FIRAuth.auth()?.signOut()
        return
    }
    
    func goToMessenger() {
        
        // Configure OneSignal pushId before goToChat
        FRAuthManager.sharedManager.handleOneSignalOnUserLogin()
        
        if self.currentUser.email == GeneralHelper.sharedHelper.appOwnerEmail {
            // SUPER ADMIN USER - SEE ALL CHATS
            self.performSegue(withIdentifier: Storyboard.segueShowRecentChats, sender: nil)
            
            
        } else {
            // CUSTOMER USER - GO DIRECTLY TO OWN USER CHAT WITH APPOWNER
            
            goCustomerChat()
            
        }
        
    }
    
    
    
    func sendGreetingMessage(_ newChat: FRChat) {
        
        let ref = FRDataManager.sharedManager.REF_USERS
        
        ref.queryOrdered(byChild: "email").queryEqual(toValue: GeneralHelper.sharedHelper.appOwnerEmail).observeSingleEvent(of: .value, with: { (snapshot) in
            
            if let snapshot = snapshot.children.allObjects as? [FIRDataSnapshot] {
                
                if let snap = snapshot.first {
                    
                    let appOwnerUser = FRUser(uid: snap.key, dictionary: snap.value as! [String: Any])
                    
                    let greetingMessage = FRMessage(chatId: newChat.uid, senderUID: appOwnerUser.uid, senderDisplayName: "Elena Senseye", text: "Здравствуйте, я могу Вам чем-то помочь?")
                    
                    greetingMessage.save()
                    
                    newChat.send(message: greetingMessage)
                    
                    
                    let chatDictionary = [
                        "chatUid": newChat.uid,
                        "lastMessage": newChat.lastMessage,
                        "withUserUID": newChat.withUserUID,
                        "withUserName": newChat.withUserName,
                        "messagesCount": newChat.messagesCount,
                        "lastUpdate": Date().timeIntervalSince1970 * 1000
                        ] as [String : Any]
                    
                    
                    KeychainWrapper.standard.set(chatDictionary as NSDictionary, forKey: KEY_CHAT_OF_USER)
                    
                    
                    self.performSegue(withIdentifier: Storyboard.segueShowChatVC, sender: newChat)
                    
                }
                
            }
            
        })
        
    }
    
    
    
    func goCustomerChat() {
        
        FRDataManager.sharedManager.REF_CHATS.child(currentUser.uid).observeSingleEvent(of: .value, with: { (snapshot) in
            
            
            if snapshot.exists() {
                print("snapshot.exists(). GO TO CHAT VIEW CONTROLLER")
                
                let chat = FRChat(uid: snapshot.key, dictionary: snapshot.value as! [String: Any])
                
                self.performSegue(withIdentifier: Storyboard.segueShowChatVC, sender: chat)
                
                
                
            } else {
                
                print("snapshot NOT exists(). CREATE NEW CHAT AND GO TO CHAT VIEW CONTROLLER")
                
                let newChat = FRChat(withUserName: self.currentUser.username, withUserUID: self.currentUser.uid)
                
                newChat.save()
                
                self.sendGreetingMessage(newChat)
                
                
            }
        })
        
        
        
    }
    
    
    func goCustomerChatWithChatCaching() {
        
        
        if let chatDict = KeychainWrapper.standard.object(forKey: KEY_CHAT_OF_USER) as? [String: Any] {
            
            print("saved chat = \(chatDict)")
            
            let uid = chatDict["chatUid"] as! String
            
            let userChat = FRChat(uid: uid, dictionary: chatDict)
            
            print("===NAG===: KeyChain chat = \(userChat.lastMessage)")
            
            self.performSegue(withIdentifier: Storyboard.segueShowChatVC, sender: userChat)
            
        } else {
            
            FRDataManager.sharedManager.REF_CHATS.child(currentUser.uid).observeSingleEvent(of: .value, with: { (snapshot) in
                
                
                if snapshot.exists() {
                    print("snapshot.exists(). GO TO CHAT VIEW CONTROLLER")
                    
                    let chat = FRChat(uid: snapshot.key, dictionary: snapshot.value as! [String: Any])
                    
                    
                    let chatDictionary = [
                        "chatUid": chat.uid,
                        "lastMessage": chat.lastMessage,
                        "withUserUID": chat.withUserUID,
                        "withUserName": chat.withUserName,
                        "messagesCount": chat.messagesCount,
                        "lastUpdate": chat.lastUpdate
                        ] as [String : Any]
                    
                    
                    KeychainWrapper.standard.set(chatDictionary as NSDictionary, forKey: KEY_CHAT_OF_USER)
                    
                    
                    self.performSegue(withIdentifier: Storyboard.segueShowChatVC, sender: chat)
                    
                    
                    
                } else {
                    
                    print("snapshot NOT exists(). CREATE NEW CHAT AND GO TO CHAT VIEW CONTROLLER")
                    
                    let newChat = FRChat(withUserName: self.currentUser.username, withUserUID: self.currentUser.uid)
                    
                    newChat.save()
                    
                    self.sendGreetingMessage(newChat)
                    
                    
                }
            })
        }
        
    }
    
    
    
    
    func resignKeyboard() {
        self.view.endEditing(true)
    }
    
    
    
    // MARK: - ACTIONS
    
    // - Facebook Login
    @IBAction func actionLoginFacebookTapped(_ sender: Any) {
        
        // Dismiss keyboard
        self.view.endEditing(true)
        
        //        SwiftSpinner.show("Logging in").addTapHandler ({
        //            SwiftSpinner.hide()
        //        })
        
        FRAuthManager.sharedManager.loginWithFacebook(viewController: self) { (errorString) in
            
            if let errorString = errorString {
                SwiftSpinner.hide()
                self.alert(title: "Error", message: errorString)
                return
                
            } else {
                
                print("===NAG===: Login Successful Using Facebook Login")
                
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
            
            print("===NAG===: Login Successful Using Firebase Email Login")
            
        })
        
    }
    
    
    @IBAction func unwindToLoginVC(segue: UIStoryboardSegue) {
        
    }
    
    
    // MARK: - NAVIGATION
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        SwiftSpinner.hide()
        
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




























