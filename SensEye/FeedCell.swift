//
//  FeedCell.swift
//  SensEye
//
//  Created by Anton Novoselov on 26/12/2016.
//  Copyright © 2016 Anton Novoselov. All rights reserved.
//

import UIKit
import Spring

// MARK: - DELEGATE
protocol FeedCellDelegate: class {
    func galleryImageViewDidTap(wallPost: WallPost, clickedPhotoIndex: Int)
    func provideAuthorization()
    func commentDidTap(post: WallPost)
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
    
    
    // MARK: - LIKE/DISLIKE FEATURE
    func toLike() {
        
        self.wallPost.postLikesCount += 1
        
        self.wallPost.isLikedByCurrentUser = true
        
        ServerManager.sharedManager.addLike(forItemType: .post, ownerID: groupID, itemID: self.wallPost.postID) { (success, resultDict) in
            self.likeButton.isUserInteractionEnabled = true
            
            if success == true {
                if let postLikesCount = resultDict?["likes"] as? Int {
                    
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
    }
    
    func toDislike() {
        
        self.wallPost.postLikesCount -= 1
        
        self.wallPost.isLikedByCurrentUser = false
        
        ServerManager.sharedManager.deleteLike(forItemType: .post, ownerID: groupID, itemID: self.wallPost.postID) { (success, resultDict) in
            self.likeButton.isUserInteractionEnabled = true
            
            if success == true {
                if let postLikesCount = resultDict?["likes"] as? Int {
                    
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
        button.animation = "pop"
        button.curve = "spring"
        button.duration = 1.25
        button.damping = 0.1
        button.velocity = 0.2
        button.animate()
    }
    
    
    // MARK: - GESTURES
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
        guard ServerManager.sharedManager.currentVKUser != nil else {
            authorize()
            return
        }
        
        likeButton.isUserInteractionEnabled = false
        
        // Force likeButton userInteraction ON after 2 sec if it's off yet
        GeneralHelper.sharedHelper.invoke(afterTimeInMs: 3000) {
            if self.likeButton.isUserInteractionEnabled == false {
                self.likeButton.isUserInteractionEnabled = true
            }
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
        
        guard ServerManager.sharedManager.currentVKUser != nil else {
            authorize()
            return
        }
        
        self.delegate?.commentDidTap(post: self.wallPost)
        
        animateButton(sender)
    }
}
