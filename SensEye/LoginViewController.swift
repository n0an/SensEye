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
        
        // Dismiss keyboard
        self.view.endEditing(true)
        
        let fbLoginManager = FBSDKLoginManager()
        
        fbLoginManager.logIn(withReadPermissions: ["public_profile", "email"], from: self) { (result, error) in
            
            
            guard error == nil else {
                print("===NAG=== Unable to authenticate with Facebook \(error!.localizedDescription)")
                
                self.alertError(error: error! as NSError)
                
                return
            }
            
            
            guard let result = result, result.isCancelled == false else { return }
            
            
            if result.token != nil {
                
                print("===NAG=== Successfully authenticated with FB")
                
                print("FBSDKAccessToken.current() = \(FBSDKAccessToken.current())")
                print("result.token = \(result.token)")

                
                print("FBSDKAccessToken.current().tokenString = \(FBSDKAccessToken.current().tokenString)")
                print("result.token.tokenString = \(result.token.tokenString)")

                
                let credential = FIRFacebookAuthProvider.credential(withAccessToken: result.token.tokenString)
                
                
                FRAuthManager.sharedManager.signInWithFacebook(withCredential: credential, onComplete: { (errorString, user) in
                    
                    guard errorString == errorString else {
                        
                        self.alert(title: "Error", message: errorString)
                        return
                    }
                    
                    DispatchQueue.main.async {
                        
                        self.goToChatVC()
                    }
                    
                    
                })
                
                
                
            }

            
            
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






























