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
    
    func provideAuthorization()
    
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
    
    
    // MARK: - awakeFromNib

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
    
    
    // MARK: - API METHODS
    
    func authorize() {
        
        
        delegate?.provideAuthorization()
        
    }
    
    
    
    // LIKE/DISLIKE FEATURE

    func toLike() {
        
        self.wallPost.postLikesCount += 1
        
        self.wallPost.isLikedByCurrentUser = true
        
        ServerManager.sharedManager.addLike(forItemType: .post, ownerID: groupID, itemID: self.wallPost.postID) { (resultDict) in
            
            if let postLikesCount = resultDict["likes"] as? Int {
                
                // Double check and correct after server response if it differs from UI
                
                if self.wallPost.postLikesCount != postLikesCount {
                    
                    self.wallPost.postLikesCount = postLikesCount
                    
                    self.wallPost.isLikedByCurrentUser = true
                    
                    self.likeButton.setTitle("\(self.wallPost.postLikesCount)", for: [])
                    
                    self.changeLikeImage()
                    
                }
                
                
            }
            
        }
    }
    
    func toDislike() {
        
        self.wallPost.postLikesCount -= 1
        
        self.wallPost.isLikedByCurrentUser = false
        
        
        ServerManager.sharedManager.deleteLike(forItemType: .post, ownerID: groupID, itemID: self.wallPost.postID) { (resultDict) in
            
            
            if let postLikesCount = resultDict["likes"] as? Int {
                
                // Double check and correct after server response if it differs from UI
                
                if self.wallPost.postLikesCount != postLikesCount {
                    
                    self.wallPost.postLikesCount = postLikesCount
                    
                    self.wallPost.isLikedByCurrentUser = false
                    
                    self.likeButton.setTitle("\(self.wallPost.postLikesCount)", for: [])
                    
                    self.changeLikeImage()
                    
                }
                
              
            }
        }
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
        
        // ** Avoid multiple calls of method
        
        UIApplication.shared.beginIgnoringInteractionEvents()
        
        let deadLineTime = DispatchTime.now() + .milliseconds(300)
        
        DispatchQueue.main.asyncAfter(deadline: deadLineTime) { 
            if UIApplication.shared.isIgnoringInteractionEvents {
                UIApplication.shared.endIgnoringInteractionEvents()
            }
        }
        
        
        
        guard ServerManager.sharedManager.currentVKUser != nil else {
            authorize()
            return
        }
        
        if currentUserLikes() {
            toDislike()
        } else {
            toLike()
        }
        
        self.likeButton.setTitle("\(self.wallPost.postLikesCount)", for: [])
        
        self.changeLikeImage()

        
        animateButton(sender)
        
    }
    
    

    @IBAction func commentDidTap(_ sender: DesignableButton) {
        print("commentDidTap")
        
        
        

        animateButton(sender)
    }

    
}














