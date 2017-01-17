//
//  ChatViewController.swift
//  SensEye
//
//  Created by Anton Novoselov on 17/01/2017.
//  Copyright © 2017 Anton Novoselov. All rights reserved.
//

import UIKit
import Firebase

class ChatViewController: UIViewController {
    
    // MARK: - OUTLETS
    @IBOutlet weak var logoutButton: UIButton!

    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()

        FIRAuth.auth()?.addStateDidChangeListener({ (auth, user) in
            
            if let user = user {
                
                DataService.instance.REF_USERS.child(user.uid).observeSingleEvent(of: .value, with: { (snapshot) in
                    
                    if let userDict = snapshot.value as? [String: Any] {
                        
                        AuthService.instance.currentUser = FUser(uid: user.uid, dictionary: userDict)
                        print("===NAG===: currentUser = \(AuthService.instance.currentUser.username)")
                        
                    }
                    
                })
                
            } else {
                
                let loginVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
                
                self.navigationController?.pushViewController(loginVC, animated: false)
            }
            
        })
    }

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.isNavigationBarHidden = true
    }
    
    // MARK: - HELPER METHODS
    func goToLoginVC() {
        
    }
    
    // MARK: - ACTIONS
    @IBAction func logoutButtonTapped() {
        
        do {
            try FIRAuth.auth()?.signOut()
            
        } catch {
            self.alertError(error: error as NSError)
        }
        
    }
    


}
