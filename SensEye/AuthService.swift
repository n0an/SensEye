//
//  AuthService.swift
//  SensEye
//
//  Created by Anton Novoselov on 16/01/2017.
//  Copyright © 2017 Anton Novoselov. All rights reserved.
//

import Foundation
import Firebase


typealias FRCompletionHandler = (String?, Any?) -> Void

class AuthService {
    
    private static let _instance = AuthService()
    
    static var instance: AuthService {
        return _instance
    }
    
    private var _currentUser: User!
    
    var currentUser: User {
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
                self.handleFirebaseError(error: error! as NSError, onComplete: onComplete)
                
            } else if let firCreatedUser = firCreatedUser {
                
                let newUser = FUser(uid: firCreatedUser.uid, username: username)
                
                newUser.save(completion: { (error) in
                    
                    if error != nil {
                        // report error
                        print("===NAG=== SAVE USER ERROR: \(error!.localizedDescription)")
                        self.handleFirebaseError(error: error as! NSError, onComplete: onComplete)
                        
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
    
    // MARK: - Helper Methods
    func completeSignIn(withEmail email: String, password: String, onComplete: FRCompletionHandler?) {
        
        FIRAuth.auth()?.signIn(withEmail: email, password: password, completion: { (firSignedUser, error) in
            if let error = error {
                self.handleFirebaseError(error: error as NSError, onComplete: onComplete)
            } else {
                // We have successfully logged in
                onComplete?(nil, firSignedUser)
            }
        })
    }
    
    
    // MARK: - Handle Firebase Errors
    func handleFirebaseError(error: NSError, onComplete: FRCompletionHandler?) {
        print("===NAG=== \(error.localizedDescription)")
        
        if let errorCode = FIRAuthErrorCode(rawValue: error.code) {
            switch errorCode {
            case .errorCodeInvalidEmail:
                onComplete?("Invalid email address", nil)
                
            case .errorCodeWrongPassword:
                onComplete?("Invalid password", nil)
                
            case .errorCodeAccountExistsWithDifferentCredential:
                fallthrough
            case .errorCodeEmailAlreadyInUse:
                onComplete?("Email already in use", nil)
                
            default:
                onComplete?("There was a problem authenticating. Try again", nil)
            }
        }
        
        onComplete?(error.localizedDescription, nil)
    }
    
}
