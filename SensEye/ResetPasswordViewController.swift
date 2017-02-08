//
//  ResetPasswordViewController.swift
//  SensEye
//
//  Created by Anton Novoselov on 16/01/2017.
//  Copyright © 2017 Anton Novoselov. All rights reserved.
//

import UIKit
import Spring

class ResetPasswordViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var containerView: DesignableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = NSLocalizedString("Forgot Password", comment: "Forgot Password")
        
        emailTextField.delegate = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.isNavigationBarHidden = false
        
        emailTextField.becomeFirstResponder()

    }

    func shake() {
        containerView.animation = "shake"
        containerView.curve = "spring"
        containerView.duration = 1.0
        containerView.animate()
    }
    
    
    
    @IBAction func actionResetPasswordButtonTapped(_ sender: Any) {
        
        // Validate the input
        guard let emailAddress = emailTextField.text,
            emailAddress != "" else {
                
                self.alert(title: NSLocalizedString("Input Error", comment: "Input Error"), message: NSLocalizedString("Please provide your email address for password reset.", comment: "Please provide your email address for password reset."))
           
                self.shake()
                
                return
        }
        
        
        FRAuthManager.sharedManager.resetPassword(emailAddress: emailAddress) { (error) in
            
            let title = (error == nil) ? NSLocalizedString("Password Reset Follow-up", comment: "Password Reset Follow-up") : NSLocalizedString("Password Reset Error", comment: "Password Reset Error")
            
            let message = (error == nil) ? NSLocalizedString("We have just sent you a password reset email. Please check your inbox and follow the instructions to reset your password.", comment: "Password Reset Success") : error?.localizedDescription
            
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



extension ResetPasswordViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        actionResetPasswordButtonTapped(self)
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










