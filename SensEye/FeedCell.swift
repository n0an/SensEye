//
//  FeedCell.swift
//  SensEye
//
//  Created by Anton Novoselov on 26/12/2016.
//  Copyright © 2016 Anton Novoselov. All rights reserved.
//

import UIKit
import Spring

protocol FeedCellDelegate: class {
    
    func galleryImageViewDidTap(wallPost: WallPost, clickedPhotoIndex: Int)
    
}

class FeedCell: UITableViewCell {

    // MARK: - OUTLETS
    @IBOutlet weak var profileImageVIew: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var timestampLabel: UILabel!
    @IBOutlet weak var postTextLabel: UILabel!
 
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var commentButton: UIButton!
    
    
    @IBOutlet weak var galleryFirstRowLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var gallerySecondRowLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var gallerySecondRowTopConstraint: NSLayoutConstraint!
    
    @IBOutlet var galleryImageViews: [UIImageView]!

    @IBOutlet var photoHeights: [NSLayoutConstraint]!
    @IBOutlet var photoWidths: [NSLayoutConstraint]!
    
    // MARK: - PROPERTIES
    var wallPost: WallPost! {
        didSet {
            
            updateUI()
            
        }
    }
    
    weak var delegate: FeedCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // *** CREATING GESTURE RECOGNIZER FOR HANDLE AUTHOR IMAGEVIEW TAP
        
        self.profileImageVIew.isUserInteractionEnabled = true
        
        let tapProfileImageViewGesture = UITapGestureRecognizer(target: self, action: #selector(actionProfileImageViewDidTap))
        
        self.profileImageVIew.addGestureRecognizer(tapProfileImageViewGesture)
        
        // Colors customizations
        
        usernameLabel.highlightedTextColor = usernameLabel.textColor
        
        // ADDING CUSTOM COLOR FOR SELECTION FOR CELL
        
        let selectedView = UIView(frame: CGRect.zero)
        selectedView.backgroundColor = cellSelectionColor
        
        selectedBackgroundView = selectedView
        
        
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        // CLEARING CELL BEFORE REUSING
        profileImageVIew.image = nil
        
        usernameLabel.text = nil
        timestampLabel.text = nil
        postTextLabel.text = nil
        
        PostPhotoGallery.sharedGalleryManager.clearGallery(forPost: wallPost, fromCell: self)
        
    }
    
    
    // MARK: - HELPER METHODS
    
    func updateUI() {
        
        
        self.postTextLabel.text = wallPost.postText
        
        self.commentButton.setTitle(wallPost.postComments, for: [])
        self.likeButton.setTitle("\(wallPost.postLikesCount)", for: [])
        
        changeLikeImage()
        
        let timeInterval = TimeInterval(wallPost.postDate)
        let createdDate = NSDate(timeIntervalSince1970: timeInterval)
        
        self.timestampLabel.text = createdDate.stringFromDate()

        
        if let postAuthor = wallPost.postAuthor {
            self.usernameLabel.text = "\(postAuthor.firstName!) \(postAuthor.lastName!)"
            
            let imageURL = URL(string: postAuthor.imageURL)
            
            self.profileImageVIew.af_setImage(withURL: imageURL!)
            
        } else if let groupPostAuthor = wallPost.postGroupAuthor {
            self.usernameLabel.text = "\(groupPostAuthor.groupName!)"
            
            let imageURL = URL(string: groupPostAuthor.imageURL)
            
            self.profileImageVIew.af_setImage(withURL: imageURL!)
            
        }
        
        PostPhotoGallery.sharedGalleryManager.insertGallery(forPost: wallPost, toCell: self)
        
    }
    
    
    func currentUserLikes() -> Bool {
        if self.wallPost.isLikedByCurrentUser == true {
            return true
        } else {
            return false
        }
    }
    
    func changeLikeImage() {
        
        if currentUserLikes() {
            likeButton.setImage(UIImage(named: "LikeYes"), for: [])
            
        } else {
            likeButton.setImage(UIImage(named: "LikeNo"), for: [])
        }
        
    }
    
    func animateButton(_ button: DesignableButton) {
        // animation
        button.animation = "pop"
        button.curve = "spring"
        button.duration = 1.25
        button.damping = 0.1
        button.velocity = 0.2
        button.animate()
    }
    
    
    
    // MARK: - GESTURES
    func actionProfileImageViewDidTap(sender: UITapGestureRecognizer) {
        print("===NAG=== actionProfileImageViewDidTap")
    }
    
    func actionGlryImageViewDidTap(sender: UITapGestureRecognizer) {
        
        guard let tappedImageView = sender.view as? UIImageView else {
            return
        }
        
        if let clickedIndex = self.galleryImageViews.index(of: tappedImageView) {
            
            self.delegate?.galleryImageViewDidTap(wallPost: self.wallPost, clickedPhotoIndex: clickedIndex)
        }
        
    }
    
    // MARK: - ACTIONS
    @IBAction func likeDidTap(_ sender: DesignableButton) {
        print("likeDidTap")
        
        
        if ServerManager.sharedManager.currentVKUser == nil {
            
            ServerManager.sharedManager.authorizeUser(completed: { (user) in
                
                ServerManager.sharedManager.currentVKUser = user
                
                print("currentVKUser = \(user)")
                
            })
            
        }
        
                
        
        if currentUserLikes() {
            self.wallPost.toDislike()
        } else {
            self.wallPost.toLike()
        }
        
        likeButton.setTitle("\(self.wallPost.postLikesCount)", for: [])
        
        changeLikeImage()
        
        animateButton(sender)
        

        
        
    }

    
    
    @IBAction func commentDidTap(_ sender: DesignableButton) {
        print("commentDidTap")

        // animation
        sender.animation = "pop"
        sender.curve = "spring"
        sender.duration = 1.5
        sender.damping = 0.1
        sender.velocity = 0.2
        sender.animate()
    }

    
}














