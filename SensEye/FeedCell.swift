//
//  FeedCell.swift
//  SensEye
//
//  Created by Anton Novoselov on 26/12/2016.
//  Copyright © 2016 Anton Novoselov. All rights reserved.
//

import UIKit
import Spring
import AlamofireImage

// MARK: - DELEGATE

class FeedCell: UITableViewCell {
    
    // MARK: - OUTLETS
    @IBOutlet weak var profileImageVIew: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var timestampLabel: UILabel!
    @IBOutlet weak var postTextLabel: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var commentButton: UIButton!
    @IBOutlet weak var postImageView: UIImageView!
    
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
        
    }
    
    // MARK: - API METHODS
    func authorize() {
        delegate?.feedCellNeedProvideAuthorization(self)
    }
    
    
    // MARK: - LIKE/DISLIKE FEATURE
    func toLike() {
        
        self.wallPost.postLikesCount += 1
        
        self.wallPost.isLikedByCurrentUser = true
        
        addLike(forItemType: .post, ownerID: groupID, itemID: self.wallPost.postID) { (success, resultDict) in
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
        
        deleteLike(forItemType: .post, ownerID: groupID, itemID: self.wallPost.postID) { (success, resultDict) in
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
        
        self.timestampLabel.text = createdDate.stringFromDate(short: false)
        
        if let postAuthor = wallPost.postAuthor {
            self.usernameLabel.text = "\(postAuthor.firstName!) \(postAuthor.lastName!)"
            let imageURL = URL(string: postAuthor.imageURL)
            self.profileImageVIew.af_setImage(withURL: imageURL!)
            
        } else if let groupPostAuthor = wallPost.postGroupAuthor {
            self.usernameLabel.text = "\(groupPostAuthor.groupName!)"
            let imageURL = URL(string: groupPostAuthor.imageURL)
            self.profileImageVIew.af_setImage(withURL: imageURL!)
        }
        
        
        insertPostImageWith(wallPost, forCell: self)

    }
    
    func insertPostImageWith(_ post: WallPost, forCell cell: FeedCell) {
        guard !post.postAttachments.isEmpty else {
            return
        }
        
        var photoObject: Photo!
        
        if let albumAttachment = post.postAttachments.first as? PhotoAlbum,
            let photoAlbumThumb = albumAttachment.albumThumbPhoto {
                photoObject = photoAlbumThumb
            
        } else if let photoAttachment = post.postAttachments.first as? Photo {
            photoObject = photoAttachment
        }
        
        var linkToNeededRes = photoObject.photo_807
        let neededRes: PhotoResolution = .res807
        
        if linkToNeededRes == "" {
            
            var index = neededRes.rawValue - 1
            
            while index >= PhotoResolution.res75.rawValue {
                let lessResKey = photoObject.keysResArray[index]
                let lessResolution = photoObject.resolutionDictionary[lessResKey]
                
                if lessResolution != nil {
                    linkToNeededRes = lessResolution!
                    break
                }
                
                index -= 1
            }
            
            if linkToNeededRes == "" {
                linkToNeededRes = photoObject.maxRes
            }
        }
        
        let urlPhoto = URL(string: linkToNeededRes!)
        
        postImageView.af_setImage(withURL: urlPhoto!)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.actionGlryImageViewDidTap))
        
        postImageView.addGestureRecognizer(tapGesture)
        
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
    @objc func actionGlryImageViewDidTap(sender: UITapGestureRecognizer) {
        
        
        self.delegate?.feedCell(self, didTapGalleryImageWith: self.wallPost, withPhotoIndex: 0)
        
    }
    
    // MARK: - ACTIONS
    @IBAction func likeDidTap(_ sender: DesignableButton) {

        guard checkIfCurrentVKUserExists() else {
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
       
        guard checkIfCurrentVKUserExists() else {
            authorize()
            return
        }
        
        self.delegate?.feedCell(self, didTapCommentFor: self.wallPost)
        
        animateButton(sender)
    }
}

extension FeedCell: AuthorizationProtocol, LikesProtocol { }
