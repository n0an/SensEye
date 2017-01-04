//
//  WallPost.swift
//  SensEye
//
//  Created by Anton Novoselov on 26/12/2016.
//  Copyright © 2016 Anton Novoselov. All rights reserved.
//

import Foundation


class WallPost: ServerObject {
    
    var postID: String!
    var postText: String!
    var postDate: Int!
    
    var postAuthorID: String!
    var postAuthor: User?
    var postGroupAuthor: Group?
    
    var postAttachments: [Any]!
    
    var postComments: String!
    var postLikes: String!
    
    required init(responseObject: [String: Any]) {
        
        if let postID = responseObject["id"] as? Int {
            
            self.postID = String(postID)
        }
        
        if let postText = responseObject["text"] as? String {
            
            self.postText = postText

        }
        
        if let postDate = responseObject["date"] as? Int {
            self.postDate = postDate

        }
        
        if let postAuthorID = responseObject["from_id"] as? Int {
            self.postAuthorID = String(postAuthorID)
        
        }
        
        
        
        let commentsDict = responseObject["comments"] as! [String: Any]
        
        if let postComments = commentsDict["count"] as? Int {
            self.postComments = String(postComments)
            
        }

        let likesDict = responseObject["likes"] as! [String: Any]
        
        if let postLikes = likesDict["count"] as? Int {
            self.postLikes = String(postLikes)
        
        }
        
        
        // Attachments
        
        guard let attachments = responseObject["attachments"] as? [Any] else {
            return
        }
        
        var attachmentsArray = [Any]()
        
        for item in attachments {
            
            let attachmentItem = item as! [String: Any]
            
            let attachmentType = attachmentItem["type"] as! String
            
            if attachmentType == "photo" {
                // Parse Photo Attachment
                
                let attachmentDict = attachmentItem["photo"] as! [String: Any]
                
                let photoAttachment = Photo(responseObject: attachmentDict)
                
                attachmentsArray.append(photoAttachment)
                
            } else if attachmentType == "album" {
                // Parse Album Attachment
                
                let attachmentDict = attachmentItem["album"] as! [String: Any]
                
                let albumAttachment = PhotoAlbum(responseObject: attachmentDict)
                
                attachmentsArray.append(albumAttachment)
            }
            
        }
        
        self.postAttachments = attachmentsArray
        
    }
    
}





extension WallPost: Equatable { }

func ==(lhs: WallPost, rhs: WallPost) -> Bool {
    return lhs.postID == rhs.postID
}
































































