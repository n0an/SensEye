//
//  CommentCell.swift
//  SensEye
//
//  Created by Anton Novoselov on 04/01/2017.
//  Copyright © 2017 Anton Novoselov. All rights reserved.
//

import UIKit
import Spring

class CommentCell: UITableViewCell {
    
    // MARK: - OUTLETS
    @IBOutlet weak var profileImageVIew: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var timestampLabel: UILabel!
    @IBOutlet weak var commentTextLabel: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    
    // MARK: - PROPERTIES
    var comment: Comment! {
        didSet {
            updateUI()
        }
    }
    
    weak var delegate: FeedCellDelegate?

    // MARK: - awakeFromNib
    override func awakeFromNib() {
        super.awakeFromNib()
        
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
        commentTextLabel.text = nil
    }
    
    
    // MARK: - API METHODS
    func authorize() {
        delegate?.provideAuthorization()
    }
    
    // LIKE/DISLIKE FEATURE
    func toLike() {
        self.comment.commentLikesCount += 1
        self.comment.isLikedByCurrentUser = true
        
        ServerManager.sharedManager.addLike(forItemType: .comment, ownerID: groupID, itemID: self.comment.commentID) { (success, resultDict) in
            self.likeButton.isUserInteractionEnabled = true
            
            if success == true {
                if let commentLikesCount = resultDict?["likes"] as? Int {
                    
                    // Double check and correct after server response if it differs from UI
                    if self.comment.commentLikesCount != commentLikesCount {
                        self.comment.commentLikesCount = commentLikesCount
                        self.comment.isLikedByCurrentUser = true
                        self.likeButton.setTitle("\(self.comment.commentLikesCount)", for: [])
                        self.changeLikeImage()
                    }
                }
            }
        }
    }
    
    func toDislike() {
        self.comment.commentLikesCount -= 1
        self.comment.isLikedByCurrentUser = false
        
        ServerManager.sharedManager.deleteLike(forItemType: .comment, ownerID: groupID, itemID: self.comment.commentID) { (success, resultDict) in
            self.likeButton.isUserInteractionEnabled = true
            
            if success == true {
                if let commentLikesCount = resultDict?["likes"] as? Int {
                    
                    // Double check and correct after server response if it differs from UI
                    if self.comment.commentLikesCount != commentLikesCount {
                        self.comment.commentLikesCount = commentLikesCount
                        self.comment.isLikedByCurrentUser = false
                        self.likeButton.setTitle("\(self.comment.commentLikesCount)", for: [])
                        self.changeLikeImage()
                    }
                }
            }
        }
    }
    
    // MARK: - HELPER METHODS
    func updateUI() {
        self.commentTextLabel.text = comment.commentText
        self.likeButton.setTitle("\(self.comment.commentLikesCount)", for: [])
        let timeInterval = TimeInterval(comment.commentDate)
        let createdDate = NSDate(timeIntervalSince1970: timeInterval)
        self.timestampLabel.text = createdDate.stringFromDate()
        
        changeLikeImage()
        
        if let commentAuthor = comment.postAuthor {
            self.usernameLabel.text = "\(commentAuthor.firstName!) \(commentAuthor.lastName!)"
            let imageURL = URL(string: commentAuthor.imageURL)
            self.profileImageVIew.af_setImage(withURL: imageURL!)
            
        } else if let groupPostAuthor = comment.postGroupAuthor {
            self.usernameLabel.text = "\(groupPostAuthor.groupName!)"
            let imageURL = URL(string: groupPostAuthor.imageURL)
            self.profileImageVIew.af_setImage(withURL: imageURL!)
        }
    }
    
    func currentUserLikes() -> Bool {
        if self.comment.isLikedByCurrentUser == true {
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
        
        self.likeButton.setTitle("\(self.comment.commentLikesCount)", for: [])
        self.changeLikeImage()
        
        animateButton(sender)
    }
    
    @IBAction func commentDidTap(_ sender: DesignableButton) {
        animateButton(sender)
    }

}
