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
    
    @IBOutlet weak var avatarImageView: UIImageView!
    
    // MARK: - PROPERTIES
    
    var avatarImage: UIImage?
    
    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.isNavigationBarHidden = false

        nameTextField.becomeFirstResponder()

        nameTextField.delegate = self
        emailTextField.delegate = self
        passwordTextField.delegate = self
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(resignKeyboard))
        self.view.addGestureRecognizer(tapGesture)
        
        let tapOnAvatarImageView = UITapGestureRecognizer(target: self, action: #selector(actionAvatarImageTapped))
        self.avatarImageView.addGestureRecognizer(tapOnAvatarImageView)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        nameTextField.becomeFirstResponder()
    }
    
    deinit {
        print("===NAG=== SignUpViewController deinit")
    }
    
    // MARK: - HELPER METHODS
    func goToChatVC() {
        
        self.dismiss(animated: true, completion: nil)
   
    }
    
    func resignKeyboard() {
        self.view.endEditing(true)
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
        
        // Dismiss keyboard
        self.view.endEditing(true)
        
        FRAuthManager.sharedManager.signUp(withEmail: email, username: username, password: password, avatarImage: avatarImage, onComplete: { (errMsg, data) in
            guard errMsg == nil else {
                self.alert(title: "Error", message: errMsg!)
                return
            }
            DispatchQueue.main.async {
                self.goToChatVC()
            }
        })
    }
    
    @IBAction func actionAvatarImageTapped() {
        
        self.view.endEditing(true)
        
        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let camera = Camera(delegate: self)
        let takePhoto = UIAlertAction(title: "Take Photo", style: .default) { (alert: UIAlertAction!) in
            camera.presentPhotoCamera(target: self, canEdit: true)
        }
        
        let sharePhoto = UIAlertAction(title: "Photo Library", style: .default) { (alert: UIAlertAction!) in
            camera.presentPhotoLibrary(target: self, canEdit: true)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (alert: UIAlertAction!) in
        }
        
        optionMenu.addAction(takePhoto)
        optionMenu.addAction(sharePhoto)
        optionMenu.addAction(cancelAction)
        
        self.present(optionMenu, animated: true, completion: nil)
        
    }

}

// MARK: - UITextFieldDelegate
extension SignUpViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField == nameTextField {
            emailTextField.becomeFirstResponder()
        } else if textField == emailTextField {
            passwordTextField.becomeFirstResponder()
        } else if textField == passwordTextField {
            passwordTextField.resignFirstResponder()
            self.actionSignUpButtonTapped(self)
        }
        
        return true
        
        
    }
    
    
}


extension SignUpViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        let editedImage = info[UIImagePickerControllerEditedImage] as! UIImage
        
        self.avatarImage = editedImage
        
        self.avatarImageView.image = editedImage
        
        
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    
}













