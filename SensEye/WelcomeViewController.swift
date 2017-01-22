//
//  WelcomeViewController.swift
//  SensEye
//
//  Created by Anton Novoselov on 17/01/2017.
//  Copyright © 2017 Anton Novoselov. All rights reserved.
//

import UIKit
import Firebase

class WelcomeViewController: UIViewController {
    
    // MARK: - OUTLETS
    @IBOutlet weak var logoutButton: UIButton!
    @IBOutlet weak var currentUserAvatarImageView: UIImageView!

    
    // MARK: - PROPERTIES
    enum Storyboard {
        static let segueShowRecentChats = "showRecentChatsViewController"
        static let segueShowChatVC = "showChatViewController"
        
    }
    
    var currentUser: FRUser!
    
    
    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()

        FIRAuth.auth()?.addStateDidChangeListener({ (auth, user) in
            
            if let user = user {
                
                FRDataManager.sharedManager.REF_USERS.child(user.uid).observeSingleEvent(of: .value, with: { (snapshot) in
                    
                    if let userDict = snapshot.value as? [String: Any] {
                        
                        FRAuthManager.sharedManager.currentUser = FRUser(uid: user.uid, dictionary: userDict)
                        self.currentUser = FRAuthManager.sharedManager.currentUser
                        
                        print("===NAG===: currentUser = \(FRAuthManager.sharedManager.currentUser.username)")
                        
                        self.goToMessenger()
                        
                        
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
    
    func goToMessenger() {
        
        if self.currentUser.uid == "WHGetHIfSjRsWRnzyY6NEHWZso52" {
            self.performSegue(withIdentifier: Storyboard.segueShowRecentChats, sender: nil)
        } else {
            self.performSegue(withIdentifier: Storyboard.segueShowChatVC, sender: nil)
        }
        
    }
    
    func fetchMessages() {
        
        if self.currentUser.avatarImage == nil {
            
            self.currentUserAvatarImageView.image = UIImage(named: "icon-defaultAvatar")
            
            self.currentUser.downloadAvatarImage { (image, error) in
                
                if let image = image {
                    
                    self.currentUserAvatarImageView.image = image
                    
                } else if let error = error {
                    self.alertError(error: error as NSError)
                }
                
                
            }
            
        } else {
            
            self.currentUserAvatarImageView.image = currentUser.avatarImage
            
        }
        
        
    }
    
    
    
    
    // MARK: - ACTIONS
    @IBAction func logoutButtonTapped() {
        
        GeneralHelper.sharedHelper.showLogoutView(onViewController: self) { (success) in
            
            if success == true {
                do {
                    try FIRAuth.auth()?.signOut()
                    
                } catch {
                    self.alertError(error: error as NSError)
                }
            }
            
        }
        
        
        
    }
    
    
    
    


}
