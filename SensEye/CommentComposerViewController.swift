//
//  CommentComposerViewController.swift
//  SensEye
//
//  Created by Anton Novoselov on 02/02/2017.
//  Copyright © 2017 Anton Novoselov. All rights reserved.
//

import UIKit

class CommentComposerViewController: UIViewController, WallPostProtocol {
    
    // MARK: - OUTLETS
    @IBOutlet weak var commentTextView: UITextView!
    @IBOutlet weak var sendButton: UIBarButtonItem!
    
    // MARK: - PROPERTIES
    var wallPost: WallPost!
    
    weak var delegate: CommentComposerViewControllerDelegate?

    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()

        title =  NSLocalizedString("New comment", comment: "New comment")
        
        sendButton.isEnabled = false
        commentTextView.text = ""
        commentTextView.delegate = self
        commentTextView.becomeFirstResponder()
    }

    // MARK: - ACTIONS
    @IBAction func sendDidTap() {
        
        createComment(ownerID: groupID, postID: wallPost.postID, message: commentTextView.text) { (success) in
            
            if success == true {
                self.dismiss(animated: true, completion: nil)
                self.delegate?.commentDidSend(withPost: self.wallPost)
            }
        }
    }
    
    @IBAction func cancelDidTap() {
        self.dismiss(animated: true, completion: nil)
    }
}

// MARK: - UITextViewDelegate
extension CommentComposerViewController: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        
        if textView.text == "" {
            sendButton.isEnabled = false
        } else {
            sendButton.isEnabled = true
        }
    }
}


