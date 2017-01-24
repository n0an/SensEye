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

import FBSDKLoginKit

class LoginViewController: UIViewController {
    
    // MARK: - OUTLETS
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: DesignableButton!

    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        emailTextField.delegate = self
        passwordTextField.delegate = self
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(resignKeyboard))
        self.view.addGestureRecognizer(tapGesture)

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
//        emailTextField.becomeFirstResponder()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if FIRAuth.auth()?.currentUser != nil {
            
            self.goToChatVC()
        }
        
        self.navigationController?.isNavigationBarHidden = true
    }
    
    deinit {
        print("===NAG=== DEINIT LoginViewController")
    }
    
    
    // MARK: - HELPER METHODS
    
    func goToChatVC() {
//        postOnLoginNotification()
        let _ = self.navigationController?.popViewController(animated: false)

        
    }
    
    func postOnLoginNotification() {
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "FRUserDidLoginNotification"), object: nil, userInfo: ["userId" : FIRAuth.auth()!.currentUser!.uid])
        
    }
    
    func resignKeyboard() {
        self.view.endEditing(true)
    }

    
    
    // MARK: - ACTIONS
    @IBAction func actionLoginFacebookTapped(_ sender: Any) {
        
        let fbLoginManager = FBSDKLoginManager()
        
        fbLoginManager.logIn(withReadPermissions: ["public_profile", "email"], from: self) { (result, error) in
            
            if let error = error {
                print("===NAG=== Unable to authenticate with Facebook \(error.localizedDescription)")

                self.alertError(error: error as NSError)
                
                
            } else if result?.isCancelled == true {
                print("===NAG=== User cancelled FB authentication")
                
            } else {
                
                if result?.token != nil {
                    
                    print("===NAG=== Successfully authenticated with FB")
                    
                    print("FBSDKAccessToken.current() = \(FBSDKAccessToken.current())")
                    
                    print("FBSDKAccessToken.current().tokenString = \(FBSDKAccessToken.current().tokenString)")
                    
                    let credential = FIRFacebookAuthProvider.credential(withAccessToken: result!.token.tokenString)
                    
                    
                    FIRAuth.auth()?.signIn(with: credential, completion: { (firuser, error) in
                        
                        
                        if let error = error {
                            print("Error loging in with facebook \(error.localizedDescription)")
                            return
                        }
                        
                        FRDataManager.sharedManager.isUserRegistered(userId: firuser!.uid, withBlock: { (isRegistered) in
                            
                            
                            if !isRegistered {
                                // NEW FACEBOOK USER
                                
                                self.createFirebaseUserFromFacebook(withBlock: { (result) in
                                    
                                    
                                    let fUser = FRUser(uid: firuser!.uid, username: result["first_name"] as! String, avatarImage: nil, pushId: "")
                                    
                                    fUser.save(completion: { (error) in
                                        
                                        if error == nil {
                                            self.goToChatVC()
                                        }
                                        
                                        
                                    })
                                    
                                })
                                
                                
                                
                                
                            } else {
                                // ALREADY REGISTERED
                                
                                
                                
                                
                            }
                            
                            
                            
                            
                            
                        })
                        
                        
                        
                        
                    })
                    
                    
                    
                    
                }
                
            }
            
            
            
            
            
            
            
        }
        
        
        
    }
    
    
    
    func createFirebaseUserFromFacebook(withBlock: @escaping ([String: Any]) -> Void) {
        
        FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "email, first_name, last_name"]).start { (connection, result, error) in
            
            if let error = error {
                
                print("Error facebook request \(error.localizedDescription)")
                return
                
            }
            
            withBlock(result as! [String: Any])
            
            
            
        }
        
    }

    
    
    
    
//    func firebaseAuth(_ credential: FIRAuthCredential) {
//        
//        FIRAuth.auth()?.signIn(with: credential, completion: { (user, error) in
//            
//            if error != nil {
//                print("===NAG=== Unable to authenticate with Firebase \(error?.localizedDescription)")
//                
//            } else {
//                print("===NAG=== Successfully authenticated with Firebase")
//                
//                if let user = user {
//                    let userData = ["provider": credential.provider]
//                    self.completeSignInWith(id: user.uid, userData: userData)
//                }
//                
//            }
//            
//            
//        })
//        
//    }
    
//    func completeSignInWith(id: String, userData: [String: String]) {
//        
//        
//        
//        
//    }
    
    
    @IBAction func actionLoginGoogleTapped(_ sender: Any) {
    }
    
    
    @IBAction func actionLoginButtonTapped(_ sender: Any) {
        
        guard let email = emailTextField.text, email != "",
            let password = passwordTextField.text, password != "" else {
            self.alert(title: "Error", message: "Enter your email and password")
            return
        }
        
        // Dismiss keyboard
        self.view.endEditing(true)
        
        
        FRAuthManager.sharedManager.loginToFireBase(withEmail: email, password: password, onComplete: { (errMsg, data) in
            
            guard errMsg == nil else {
                
                self.alert(title: "Error", message: errMsg!)
                return
            }
            
            DispatchQueue.main.async {
                
                self.goToChatVC()
            }
        })

        

        
        
    }
    
    
    @IBAction func unwindToLoginVC(segue: UIStoryboardSegue) {
        
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






























