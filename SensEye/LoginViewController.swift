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
    @IBOutlet weak var emailTextField: DesignableTextField!
    @IBOutlet weak var passwordTextField: DesignableTextField!
    @IBOutlet weak var loginButton: DesignableButton!
    @IBOutlet weak var loginFacebookButton: FancyButton!
    @IBOutlet weak var loginGoogleButton: FancyButton!
    @IBOutlet weak var signUpButton: FancyButton!
    @IBOutlet weak var resetPasswordButton: UIButton!
    @IBOutlet weak var containerView: DesignableView!
    @IBOutlet weak var hideKeyboardInputAccessoryView: UIView!
    
    // MARK: - PROPERTIES
    enum Storyboard {
        static let segueShowRecentChats = "showRecentChatsViewController"
        static let segueShowChatVC      = "showChatViewController"
    }
    
    var currentUser: FRUser!
    
    var isCurrentVC: Bool {
        let tabBarController = UIApplication.shared.keyWindow?.rootViewController as! UITabBarController
        
        if tabBarController.selectedIndex == TabBarIndex.chat.rawValue {
            return true
        } else {
            return false
        }
    }
    
    var isMessengerLoading = false {
        willSet {
            emailTextField.isEnabled        = !newValue
            passwordTextField.isEnabled     = !newValue
            loginButton.isEnabled           = !newValue
            signUpButton.isEnabled          = !newValue
            resetPasswordButton.isEnabled   = !newValue
            loginFacebookButton.isEnabled   = !newValue
            loginGoogleButton.isEnabled     = !newValue
        }
    }
    
    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        emailTextField.inputAccessoryView = hideKeyboardInputAccessoryView
        passwordTextField.inputAccessoryView = hideKeyboardInputAccessoryView
       
        FIRAuth.auth()?.addStateDidChangeListener({ (auth, user) in
            
            if let user = user {
                
                if self.currentUser != nil {
                    return
                }
                
                print("===== addStateDidChangeListener isMessengerLoading = true")
                self.isMessengerLoading = true
                
                // IF DIDN'T ENTER CHAT AFTER 60 SEC - FORCE LOGOUT
//                self.forceLogoutAfter(time: 100)
                
                if self.isCurrentVC {
                    SwiftSpinner.show(NSLocalizedString("Entering chat", comment: "SPINNER_ENTER_CHAT")).addTapHandler({
                        SwiftSpinner.hide()
                    })
                }
                
                // ** Checking if there's CurrentUser in Keychain
                if let userDict = KeychainWrapper.standard.object(forKey: KEY_CHAT_USER) as? [String: Any] {
                    let uid = userDict["uid"] as! String
                    
                    FRAuthManager.sharedManager.currentUser = FRUser(uid: uid, dictionary: userDict)
                    self.currentUser = FRAuthManager.sharedManager.currentUser
                    
                    DispatchQueue.main.async {
                        print("GO FROM Listener")
                        self.goToMessenger()
                    }
                    
                } else {
                    // ** Get user from Firebase, if not found in Keychain
                    FRDataManager.sharedManager.REF_USERS.child(user.uid).observeSingleEvent(of: .value, with: { (snapshot) in
                        
                        if let userDict = snapshot.value as? [String: Any] {
                            FRAuthManager.sharedManager.currentUser = FRUser(uid: user.uid, dictionary: userDict)
                            self.currentUser = FRAuthManager.sharedManager.currentUser
                            
                            let userDictionary = [
                                "uid"       : self.currentUser.uid,
                                "username"  : self.currentUser.username,
                                "pushId"    : self.currentUser.pushId!,
                                "email"     : self.currentUser.email
                            ]
                            
                            KeychainWrapper.standard.set(userDictionary as NSDictionary, forKey: KEY_CHAT_USER)
                            
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
        
        if self.currentUser != nil {
            return
        }
        
        
        if let userDict = KeychainWrapper.standard.object(forKey: KEY_CHAT_USER) as? [String: Any] {
            
            print("===== viewDidAppear isMessengerLoading = true")
            self.isMessengerLoading = true
            
            SwiftSpinner.show(NSLocalizedString("Entering chat", comment: "SPINNER_ENTER_CHAT")).addTapHandler({
                SwiftSpinner.hide()
            })
            
            let uid = userDict["uid"] as! String
            
            FRAuthManager.sharedManager.currentUser = FRUser(uid: uid, dictionary: userDict)
            self.currentUser = FRAuthManager.sharedManager.currentUser
            
            DispatchQueue.main.async {
                print("GO FROM viewDidAppear")
                self.goToMessenger()
            }
        }
    }
    
    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransition(to: newCollection, with: coordinator)
        self.resignKeyboard()
    }
    
    // MARK: - HELPER METHODS
    func forceLogoutAfter(time seconds: Int) {
        
        GeneralHelper.sharedHelper.invoke(afterTimeInMs: seconds * 1000) {
            if self.navigationController?.viewControllers.count == 1 {
                SwiftSpinner.hide()
                self.isMessengerLoading = false
                
                print("==!! forceLogoutAfter !!==")
                
                if FIRAuth.auth()?.currentUser != nil {
                    FRAuthManager.sharedManager.logOut(onComplete: { (error) in
                        
                    })
                }
            }
        }
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
                    
                    let greetingMessage = FRMessage(chatId: newChat.uid,
                                                    senderUID: appOwnerUser.uid,
                                                    senderDisplayName: "Elena Senseye",
                                                    text: NSLocalizedString("Hello. How can I help you?", comment: "GREETIN_MESSAGE"))
                    greetingMessage.save()
                    
                    newChat.send(message: greetingMessage)
                    
                    let chatDictionary = [
                        "chatUid"       : newChat.uid,
                        "lastMessage"   : newChat.lastMessage,
                        "withUserUID"   : newChat.withUserUID,
                        "withUserName"  : newChat.withUserName,
                        "messagesCount" : newChat.messagesCount,
                        "lastUpdate"    : Date().timeIntervalSince1970 * 1000
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
                let chat = FRChat(uid: snapshot.key, dictionary: snapshot.value as! [String: Any])
                self.performSegue(withIdentifier: Storyboard.segueShowChatVC, sender: chat)
                
            } else {
                let newChat = FRChat(withUserName: self.currentUser.username, withUserUID: self.currentUser.uid)
                newChat.save()
                self.sendGreetingMessage(newChat)
            }
        })
    }
    
    func goCustomerChatWithChatCaching() {
        
        if let chatDict = KeychainWrapper.standard.object(forKey: KEY_CHAT_OF_USER) as? [String: Any] {
            let uid = chatDict["chatUid"] as! String
            let userChat = FRChat(uid: uid, dictionary: chatDict)
            self.performSegue(withIdentifier: Storyboard.segueShowChatVC, sender: userChat)
            
        } else {
            
            FRDataManager.sharedManager.REF_CHATS.child(currentUser.uid).observeSingleEvent(of: .value, with: { (snapshot) in
                
                if snapshot.exists() {
                    let chat = FRChat(uid: snapshot.key, dictionary: snapshot.value as! [String: Any])
                    
                    let chatDictionary = [
                        "chatUid"       : chat.uid,
                        "lastMessage"   : chat.lastMessage,
                        "withUserUID"   : chat.withUserUID,
                        "withUserName"  : chat.withUserName,
                        "messagesCount" : chat.messagesCount,
                        "lastUpdate"    : chat.lastUpdate
                        ] as [String : Any]
                    
                    KeychainWrapper.standard.set(chatDictionary as NSDictionary, forKey: KEY_CHAT_OF_USER)
                    self.performSegue(withIdentifier: Storyboard.segueShowChatVC, sender: chat)
                    
                } else {
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
    
    
    func shake() {
        containerView.animation     = "shake"
        containerView.curve         = "spring"
        containerView.duration      = 1.0
        containerView.animate()
    }
    
    // MARK: - ACTIONS
    // MARK: - Facebook Login
    @IBAction func actionLoginFacebookTapped(_ sender: Any) {
        
        self.view.endEditing(true)
        
        FRAuthManager.sharedManager.loginWithFacebook(viewController: self) { (errorString) in
            
            if let errorString = errorString {
                SwiftSpinner.hide()
                
                self.alert(title: NSLocalizedString("Error", comment: "Error"), message: errorString)
                self.isMessengerLoading = false
                
                return
            }
        }
    }
    
    // MARK: - Google Login
    @IBAction func actionLoginGoogleTapped(_ sender: Any) {
        
        self.view.endEditing(true)
        
        GIDSignIn.sharedInstance().signIn()
    }
    
    
    // MARK: - Email/Password Login
    @IBAction func actionLoginButtonTapped(_ sender: Any) {
        
        guard let email = emailTextField.text, email != "",
            let password = passwordTextField.text, password != "" else {
                self.alert(title: NSLocalizedString("Error", comment: "Error"),
                           message: NSLocalizedString("Enter your email and password", comment: ""))
                
                self.shake()
                return
        }
        
        emailTextField.text = ""
        passwordTextField.text = ""
        
        self.view.endEditing(true)
        
        SwiftSpinner.show(NSLocalizedString("Logging In", comment: "")).addTapHandler ({
            SwiftSpinner.hide()
        })
        
        print("===== actionLoginButtonTapped isMessengerLoading = true")
        self.isMessengerLoading = true
        
        FRAuthManager.sharedManager.loginToFireBase(withEmail: email, password: password, onComplete: { (errMsg, data) in
            
            guard errMsg == nil else {
                SwiftSpinner.hide()
                self.alert(title: NSLocalizedString("Error", comment: "Error"), message: errMsg!)
                print("=====  loginToFireBase ERROR isMessengerLoading = false")
                self.isMessengerLoading = false
                return
            }
            // Login Successful Using Firebase Email Login
        })
    }
    
    @IBAction func hideKeyboard() {
        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
    }
    
    
    @IBAction func unwindToLoginVC(segue: UIStoryboardSegue) {
        
    }
    
    // MARK: - NAVIGATION
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        SwiftSpinner.hide()
        print("===== prepareForSegue isMessengerLoading = false")
        self.isMessengerLoading = false
        
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

// MARK: - UITextFieldDelegate
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
    
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if textField == emailTextField {
            let checkResult = TextFieldsChecker.sharedChecker.handleEmailTextField(textField, inRange: range, withReplacementString: string)
            
            return checkResult
        }
        
        return true
    }
}





