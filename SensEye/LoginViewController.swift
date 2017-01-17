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

class LoginViewController: UIViewController {
    
    // MARK: - OUTLETS
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: DesignableButton!

    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if FIRAuth.auth()?.currentUser != nil {
            
            self.goToChatVC()
        }
        
        self.navigationController?.isNavigationBarHidden = true
    }
    
    deinit {
        print("===NAG=== LoginViewController deinit")
    }
    
    
    // MARK: - HELPER METHODS
    
    func goToChatVC() {
        
        let _ = self.navigationController?.popViewController(animated: false)

        
    }

    
    
    // MARK: - ACTIONS
    @IBAction func actionLoginFacebookTapped(_ sender: Any) {
    }
    
    
    @IBAction func actionLoginGoogleTapped(_ sender: Any) {
    }
    
    
    @IBAction func actionLoginButtonTapped(_ sender: Any) {
        
        guard let email = emailTextField.text, emailTextField.text != "" else {
            self.alert(title: "Email", message: "Enter your email")
            return
        }
        
        guard let password = passwordTextField.text, passwordTextField.text != "" else {
            self.alert(title: "Password", message: "Enter you password")
            return
        }
        
        AuthService.instance.loginToFireBase(withEmail: email, password: password, onComplete: { (errMsg, data) in
            
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
