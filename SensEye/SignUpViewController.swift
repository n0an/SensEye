//
//  SignUpViewController.swift
//  SensEye
//
//  Created by Anton Novoselov on 16/01/2017.
//  Copyright © 2017 Anton Novoselov. All rights reserved.
//

import UIKit
import Spring

class SignUpViewController: UIViewController {

    // MARK: - OUTLETS
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signUpButton: DesignableButton!
    
    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.isNavigationBarHidden = false

        nameTextField.becomeFirstResponder()

        nameTextField.delegate = self
        emailTextField.delegate = self
        passwordTextField.delegate = self
    }
    
    deinit {
        print("===NAG=== SignUpViewController deinit")
    }
    
    // MARK: - HELPER METHODS
    func goToChatVC() {
        
        self.dismiss(animated: true, completion: nil)
   
    }

    // MARK: - ACTIONS
    @IBAction func actionSignUpButtonTapped(_ sender: Any) {
        
        // Validate the input
        
        guard let username = nameTextField.text, username != "",
            let email = emailTextField.text, email != "",
            let password = passwordTextField.text, password != "" else {
                
                self.alert(title: "Sign Up Error", message: "Please make sure you provide your name, email address and password to complete the registration.", handler: nil)
                
                return
        }
        
        FRAuthManager.sharedManager.signUp(withEmail: email, username: username, password: password, onComplete: { (errMsg, data) in
            
            guard errMsg == nil else {
                
                self.alert(title: "Error", message: errMsg!)
                return
            }
 
            self.goToChatVC()
            
        })

        
        
    }
    

}

extension SignUpViewController: UITextFieldDelegate {
    
}













