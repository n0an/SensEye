//
//  FRAuthManager.swift
//  SensEye
//
//  Created by Anton Novoselov on 16/01/2017.
//  Copyright © 2017 Anton Novoselov. All rights reserved.
//

import Foundation
import Firebase


typealias FRAuthCompletionHandler = (_ errorString: String?, _ firUser: Any?) -> Void

class FRAuthManager {
    
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
                
                let newUser = FRUser(uid: firCreatedUser.uid, username: username, avatarImage: avatarImage, pushId: "")
                
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
    func updateOneSignalId() {
        
        if let pushId = UserDefaults.standard.string(forKey: "OneSignalId") {
            
            setOneSignalId(pushId: pushId)
            
        } else {
            removeOneSignalId()
        }
    }
    
    
    func setOneSignalId(pushId: String) {
        
        updateCurrentUserOneSignalId(newId: pushId)
        
    }
    
    
    func removeOneSignalId() {
        updateCurrentUserOneSignalId(newId: "")
    }
    
    
    func updateCurrentUserOneSignalId(newId: String) {
        
        let currentUser = self.currentUser
        
        currentUser.pushId = newId
        
        saveUserToUserDefaults(user: currentUser)
        
        currentUser.userRef.setValue(currentUser.toDictionary())
        
        
    }
    
    
    
    func saveUserToUserDefaults(user: FRUser) {
        
        UserDefaults.standard.set(user.toDictionary(), forKey: "currentUser")
        UserDefaults.standard.synchronize()
        
    }
  
    
}
















