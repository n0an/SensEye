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
        
        if FIRAuth.auth()?.currentUser != nil {
            self.goToChatVC()
        }
        
        
    }
    
    
    // MARK: - HELPER METHODS
    
    func goToChatVC() {
        
        let chatVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ChatVC") as! ChatViewController
        
        self.present(chatVC, animated: false, completion: nil)
        
    }

    
    
    // MARK: - ACTIONS
    @IBAction func actionLoginFacebookTapped(_ sender: Any) {
    }
    
    
    @IBAction func actionLoginGoogleTapped(_ sender: Any) {
    }
    
    
    @IBAction func actionLoginButtonTapped(_ sender: Any) {
        
        if emailTextField.text != "" && (passwordTextField.text?.characters.count)! > 6 {
            let email = emailTextField.text!
            let password = passwordTextField.text!
            
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
        
        
    }
    
    
    @IBAction func unwindToLoginVC(segue: UIStoryboardSegue) {
        
    }
    

}
