//
//  SignUpViewController.swift
//  SensEye
//
//  Created by Anton Novoselov on 16/01/2017.
//  Copyright © 2017 Anton Novoselov. All rights reserved.
//

import UIKit
import Spring
import Firebase
import SwiftSpinner

class SignUpViewController: UIViewController {

    // MARK: - OUTLETS
    @IBOutlet weak var nameTextField: DesignableTextField!
    @IBOutlet weak var emailTextField: DesignableTextField!
    @IBOutlet weak var passwordTextField: DesignableTextField!
    @IBOutlet weak var signUpButton: DesignableButton!
    
    @IBOutlet weak var avatarImageView: UIImageView!
    
    @IBOutlet weak var containerView: DesignableView!
    
    @IBOutlet weak var hideKeyboardInputAccessoryView: UIView!

    
    // MARK: - PROPERTIES
    
    var avatarImage: UIImage?
    
    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.isNavigationBarHidden = false


        nameTextField.delegate = self
        emailTextField.delegate = self
        passwordTextField.delegate = self
        
        nameTextField.inputAccessoryView = hideKeyboardInputAccessoryView
        emailTextField.inputAccessoryView = hideKeyboardInputAccessoryView
        passwordTextField.inputAccessoryView = hideKeyboardInputAccessoryView
        
        
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(resignKeyboard))
        self.view.addGestureRecognizer(tapGesture)
        
        let tapOnAvatarImageView = UITapGestureRecognizer(target: self, action: #selector(actionAvatarImageTapped))
        self.avatarImageView.addGestureRecognizer(tapOnAvatarImageView)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        nameTextField.becomeFirstResponder()
    }
    
    override func viewWillLayoutSubviews() {
        self.resignKeyboard()
    }
    
    // MARK: - HELPER METHODS
    func goToChatVC() {

        self.dismiss(animated: true, completion: nil)
   
    }
    
    func resignKeyboard() {
        self.view.endEditing(true)
    }
    
    func shake() {
        containerView.animation = "shake"
        containerView.curve = "spring"
        containerView.duration = 1.0
        containerView.animate()
    }
    
    

    // MARK: - ACTIONS
    @IBAction func actionSignUpButtonTapped(_ sender: Any) {
        // Validate the input
        guard let username = nameTextField.text, username != "",
            let email = emailTextField.text, email != "",
            let password = passwordTextField.text, password != "" else {
                
                self.alert(
                    title: NSLocalizedString("Sign Up Error", comment: "Sign Up Error"),
                    message: NSLocalizedString("Please make sure you provided your name, email address and password to complete the registration.", comment: "SIGNUP_ERROR_MESSAGE"), handler: nil)
                self.shake()
                return
        }
        
        
        
        // Dismiss keyboard
        self.view.endEditing(true)
        
        // Show spinner
        SwiftSpinner.show(NSLocalizedString("Registering new account", comment: "Registering new account")).addTapHandler ({
            SwiftSpinner.hide()
        })
        
        
        
        FRAuthManager.sharedManager.signUp(withEmail: email, username: username, password: password, avatarImage: avatarImage, onComplete: { (errMsg, data) in
            guard errMsg == nil else {
                SwiftSpinner.hide()
                self.alert(title: NSLocalizedString("Error", comment: "Error"), message: errMsg!)
                return
            }
            
            
            
            SwiftSpinner.hide()
            self.goToChatVC()
            
        })
    }
    
    @IBAction func actionAvatarImageTapped() {
        
        self.view.endEditing(true)
        
        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let camera = Camera(delegate: self)
        let takePhoto = UIAlertAction(title: NSLocalizedString("Take Photo", comment: "Take Photo"), style: .default) { (alert: UIAlertAction!) in
            camera.presentPhotoCamera(target: self, canEdit: true)
        }
        
        let sharePhoto = UIAlertAction(title: NSLocalizedString("Photo Library", comment: "Photo Library"), style: .default) { (alert: UIAlertAction!) in
            camera.presentPhotoLibrary(target: self, canEdit: true)
        }
        
        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel"), style: .cancel) { (alert: UIAlertAction!) in
        }
        
        optionMenu.addAction(takePhoto)
        optionMenu.addAction(sharePhoto)
        optionMenu.addAction(cancelAction)
        
        optionMenu.popoverPresentationController?.sourceView = self.avatarImageView
        
        self.present(optionMenu, animated: true, completion: nil)
        
    }
    
    @IBAction func hideKeyboard() {
        nameTextField.resignFirstResponder()
        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        
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













