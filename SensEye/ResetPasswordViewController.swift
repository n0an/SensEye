//
//  ResetPasswordViewController.swift
//  SensEye
//
//  Created by Anton Novoselov on 16/01/2017.
//  Copyright © 2017 Anton Novoselov. All rights reserved.
//

import UIKit

class ResetPasswordViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Forgot Password"
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.isNavigationBarHidden = false
        
        emailTextField.becomeFirstResponder()

    }

    deinit {
        print("===NAG=== DEINIT RecetPasswordViewController")
    }
    
    @IBAction func actionResetPasswordButtonTapped(_ sender: Any) {
        
        // Validate the input
        guard let emailAddress = emailTextField.text,
            emailAddress != "" else {
                
                self.alert(title: "Input Error", message: "Please provide your email address for password reset.")
                
//                let alertController = UIAlertController(title: "Input Error", message: "Please provide your email address for password reset.", preferredStyle: .alert)
//                let okayAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
//                alertController.addAction(okayAction)
//                present(alertController, animated: true, completion: nil)
                
                return
        }
        
        
        FRAuthManager.sharedManager.resetPassword(emailAddress: emailAddress) { (error) in
            
            let title = (error == nil) ? "Password Reset Follow-up" : "Password Reset Error"
            let message = (error == nil) ? "We have just sent you a password reset email. Please check your inbox and follow the instructions to reset your password." : error?.localizedDescription
            
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let okayAction = UIAlertAction(title: "OK", style: .cancel, handler: { (action) in
                
                if error == nil {
                    
                    // Dismiss keyboard
                    self.view.endEditing(true)
                    
                    // Return to the login screen
                    if let navController = self.navigationController {
                        navController.popViewController(animated: true)
                    }
                }
            })
            alertController.addAction(okayAction)
            
            self.present(alertController, animated: true, completion: nil)
            
            
        }
        
        
    }

}
