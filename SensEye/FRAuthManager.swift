//
//  FRAuthManager.swift
//  SensEye
//
//  Created by Anton Novoselov on 16/01/2017.
//  Copyright © 2017 Anton Novoselov. All rights reserved.
//

import Foundation
import Firebase
import FBSDKLoginKit

import GoogleSignIn

import OneSignal

import SAMCache

import SwiftKeychainWrapper

typealias FRAuthCompletionHandler = (_ errorString: String?, _ firUser: Any?) -> Void

class FRAuthManager: NSObject {
    
    private static let _sharedManager = FRAuthManager()
    
    static var sharedManager: FRAuthManager {
        
        
        return _sharedManager
    }
    
    
    private var _currentUser: FRUser!
    
    var currentUser: FRUser {
        set {
            _currentUser = newValue
        } get {
            return _currentUser
        }
    }
    
    
    
    // MARK: - Sign Up Method
    func signUp(withEmail email: String, username: String, password: String, avatarImage: UIImage?, onComplete: FRAuthCompletionHandler?) {
        
        FIRAuth.auth()?.createUser(withEmail: email, password: password, completion: { (firCreatedUser, error) in
            
            if let error = error {
                // report error
                onComplete?(error.localizedDescription, nil)
                
            } else if let firCreatedUser = firCreatedUser {
                
                
                let newUser = FRUser(uid: firCreatedUser.uid, username: username, email: firCreatedUser.email!, avatarImage: avatarImage, pushId: "")
                
                newUser.save(completion: { (error) in
                    
                    if let error = error {
                        // report error
                        onComplete?(error.localizedDescription, nil)
                        
                    } else {
                        // SUCCESS - NEW USER CREATED AND SAVED TO DATABASE - SIGN IN NOW
                        self.completeSignIn(withEmail: email, password: password, onComplete: onComplete)
                    }
                })
            }
        })
    }
    
    // MARK: - Log In Method
    func loginToFireBase(withEmail email: String, password: String, onComplete: FRAuthCompletionHandler?) {
        self.completeSignIn(withEmail: email, password: password, onComplete: onComplete)
    }
    
    
    func resetPassword(emailAddress: String, completion: @escaping (Error?) -> Void) {
        
        // Send password reset email
        
        FIRAuth.auth()?.sendPasswordReset(withEmail: emailAddress, completion: { (error) in
            
            
            completion(error)
            
            
        })
        
    }
    
    
    // MARK: - FACEBOOK LOGIN METHODS
    
    
    func loginWithFacebook(viewController: UIViewController, onComplete: @escaping (String?) -> Void) {
        
        let fbLoginManager = FBSDKLoginManager()
        
        
        fbLoginManager.logIn(withReadPermissions: ["public_profile", "email"], from: viewController) { (result, error) in
            
            
            guard error == nil else {
                print("===NAG=== Unable to authenticate with Facebook \(error!.localizedDescription)")
                
                viewController.alertError(error: error! as NSError)
                
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
                
                
                self.signInWithFacebook(withCredential: credential, onComplete: { (errorString, user) in
                    
                    
                    if let errorString = errorString {
                        onComplete(errorString)
                    } else {
                        onComplete(nil)
                    }
                    
                    
                    
                })
                
                
                
            }
            
            
            
        }
        
    }
    
    
    
    
    
    func signInWithFacebook(withCredential credential: FIRAuthCredential, onComplete: FRAuthCompletionHandler?) {
        
        FIRAuth.auth()?.signIn(with: credential, completion: { (firuser, error) in
            
            if let error = error {
                print("Error loging in with facebook \(error.localizedDescription)")
                // report error
                onComplete?(error.localizedDescription, nil)
                
                
            } else if let firuser = firuser {
                
                
                self.createFirebaseUserFromFacebook(withBlock: { (result) in
                    
                    let userFirstName = result["first_name"] as! String
                    let userLastName = result["last_name"] as! String
                    
                    let fullName = "\(userFirstName) \(userLastName)"
                    
                    let email = firuser.email!
                    
                    let provider = credential.provider
                    
                    let userRef = FRDataManager.sharedManager.REF_USERS.child(firuser.uid)
                    
                    userRef.child("username").setValue(fullName)
                    userRef.child("email").setValue(email)
                    userRef.child("provider").setValue(provider)
                    userRef.child("pushId").setValue("")
                    
                    onComplete?(nil, firuser)
                    
 
                })
                
            }
            
        })
        
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
    
    // MARK: - Log Out Method
    
    func logOut(onComplete: (Error?) -> Void) {
        
        do {
            
            KeychainWrapper.standard.removeObject(forKey: KEY_CHAT_USER)
            KeychainWrapper.standard.removeObject(forKey: KEY_CHAT_OF_USER)
            
            SAMCache.shared().removeAllObjects()
            
            if self._currentUser != nil {
                
                self.updateCurrentUserOneSignalId(newId: "")
            }
            
            
            try FIRAuth.auth()?.signOut()
            
        } catch {
            onComplete(error)
        }
    }
    
    
    
    
    // MARK: - HELPER METHODS
    func completeSignIn(withEmail email: String, password: String, onComplete: FRAuthCompletionHandler?) {
        
        FIRAuth.auth()?.signIn(withEmail: email, password: password, completion: { (firSignedUser, error) in
            
            if let error = error {
                onComplete?(error.localizedDescription, nil)

            } else {
                // SUCCESS - SINGED IN
                onComplete?(nil, firSignedUser)
            }
        })
    }
    
    
    
    
    
    
    // MARK: - PUSH NOTIFICATIOINS CONFIGURATION
    
    func handleOneSignalOnUserLogin() {
        
        OneSignal.idsAvailable { (userId, token) in
            
            var pushId = ""
            
            if token != nil {
                
                pushId = userId!
                
            }
            
            self.updateCurrentUserOneSignalId(newId: pushId)
            
        }
        
    }
    
  
    
    func updateCurrentUserOneSignalId(newId: String) {
        
        let currentUser = self.currentUser
        
        currentUser.pushId = newId
        
        currentUser.userRef.child("pushId").setValue(newId)
        
    }
    
   
    
}


// MARK: - GOOGLE LOGIN
extension FRAuthManager: GIDSignInDelegate {
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        
        if let error = error {
            print("Google SignIn Error: \(error.localizedDescription)")
            return
        }
        
        guard let authentication = user.authentication else { return }
        
        let credential = FIRGoogleAuthProvider.credential(withIDToken: authentication.idToken, accessToken: authentication.accessToken)
        
        print("authentication = \(authentication)")
        print("authentication.idToken = \(authentication.idToken)")
        print("authentication.accessToken = \(authentication.accessToken)")
        
        print("Google credential = \(credential)")
        
        FIRAuth.auth()?.signIn(with: credential, completion: { (firuser, error) in
            
            if let error = error {
                print("Google SignIn Error: \(error.localizedDescription)")
                return
            }
            
            
            let userRef = FRDataManager.sharedManager.REF_USERS.child(firuser!.uid)
            
            let fullName = user.profile.name
            
            let email = firuser!.email!
            
            let provider = credential.provider
            
            userRef.child("username").setValue(fullName)
            userRef.child("email").setValue(email)
            userRef.child("provider").setValue(provider)
            userRef.child("pushId").setValue("")

        })
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        
        
        
    }
    
    
}












