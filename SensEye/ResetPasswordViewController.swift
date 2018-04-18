//
//  ResetPasswordViewController.swift
//  SensEye
//
//  Created by Anton Novoselov on 16/01/2017.
//  Copyright © 2017 Anton Novoselov. All rights reserved.
//

import UIKit
import Spring

class ResetPasswordViewController: UIViewController, Alertable {

    // MARK: - OUTLETS
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var resetPasswordButton: FancyButton!
    @IBOutlet weak var containerView: DesignableView!
    
    @IBOutlet weak var gradientView: GradientView!
    
    
    // MARK: - PROPERTIES
    
    var isUILocked = false {
        willSet {
            emailTextField.isEnabled        = !newValue
            resetPasswordButton.isEnabled   = !newValue
        }
    }
    
    var isFlipped = false
    
    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.gradientView.flip(delay: 0, duration: 0)

        self.title = NSLocalizedString("Forgot Password", comment: "Forgot Password")
        emailTextField.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.isNavigationBarHidden = false
        emailTextField.becomeFirstResponder()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if !isFlipped {
            self.gradientView.flip(delay: 0.1, duration: 0.3)
            isFlipped = true
        }
    }

    // MARK: - HELPER METHODS
    func shake() {
        containerView.animation     = "shake"
        containerView.curve         = "spring"
        containerView.duration      = 1.0
        containerView.animate()
    }
    
    // MARK: - ACTIONS
    @IBAction func actionResetPasswordButtonTapped(_ sender: Any) {
        
        guard let emailAddress = emailTextField.text,
            emailAddress != "" else {
                self.alert(title: NSLocalizedString("Input Error", comment: "Input Error"),
                           message: NSLocalizedString("Please provide your email address for password reset.", comment: "Please provide your email address for password reset."))
                self.shake()
                return
        }
        
        self.isUILocked = true
        
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
            
            self.isUILocked = false
            
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
}

// MARK: - UITextFieldDelegate
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




