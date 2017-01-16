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

    @IBOutlet weak var nameTextField: UITextField!
    
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var signUpButton: DesignableButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        nameTextField.becomeFirstResponder()

        
    }

    @IBAction func actionSignUpButtonTapped(_ sender: Any) {
        
        // Validate the input
        guard let name = nameTextField.text, name != "",
            let emailAddress = emailTextField.text, emailAddress != "",
            let password = passwordTextField.text, password != "" else {
                
                self.alert(title: "Registration Error", message: "Please make sure you provide your name, email address and password to complete the registration.", handler: nil)
                
                return
        }
        
        

        
        
    }
    

}
