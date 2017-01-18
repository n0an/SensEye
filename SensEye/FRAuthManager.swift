//
//  FRAuthManager.swift
//  SensEye
//
//  Created by Anton Novoselov on 16/01/2017.
//  Copyright © 2017 Anton Novoselov. All rights reserved.
//

import Foundation
import Firebase


typealias FRCompletionHandler = (_ errorString: String?, _ firUser: Any?) -> Void

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
    func signUp(withEmail email: String, username: String, password: String, onComplete: FRCompletionHandler?) {
        
        FIRAuth.auth()?.createUser(withEmail: email, password: password, completion: { (firCreatedUser, error) in
            
            if error != nil {
                // report error
                onComplete?(error?.localizedDescription, nil)
                
            } else if let firCreatedUser = firCreatedUser {
                
                let newUser = FRUser(uid: firCreatedUser.uid, username: username)
                
                newUser.save(completion: { (error) in
                    
                    if error != nil {
                        // report error
                        onComplete?(error?.localizedDescription, nil)
                        
                    } else {
                        
                        self.completeSignIn(withEmail: email, password: password, onComplete: onComplete)
                    }
                })
            }
        })
    }
    
    // MARK: - Log In Method
    func loginToFireBase(withEmail email: String, password: String, onComplete: FRCompletionHandler?) {
        self.completeSignIn(withEmail: email, password: password, onComplete: onComplete)
    }
    
    // MARK: - HELPER METHODS
    func completeSignIn(withEmail email: String, password: String, onComplete: FRCompletionHandler?) {
        
        FIRAuth.auth()?.signIn(withEmail: email, password: password, completion: { (firSignedUser, error) in
            
            if let error = error {
                onComplete?(error.localizedDescription, nil)

            } else {
                // SUCCESS - NEW USER CREATED, SINGED IN AND SAVED TO DATABASE
                onComplete?(nil, firSignedUser)
            }
        })
    }
    
    
  
    
}
