//
//  WallPost.swift
//  SensEye
//
//  Created by Anton Novoselov on 26/12/2016.
//  Copyright © 2016 Anton Novoselov. All rights reserved.
//

import Foundation


class WallPost {
    
    var postID: String!
    var postText: String!
    var postDate: Int!
    
    var postAuthorID: String!
    var postAuthor: User?
    var postGroupAuthor: Group?
    
    var postAttachments: [Any]!
    
    var postComments: String!
    var postLikes: String!
    
    init(responseObject: [String: Any]) {
        
        if let postID = responseObject["id"] as? Int {
            
            self.postID = String(postID)
            
            print("===NAG=== self.postID = \(self.postID!)")
        }
        
        if let postText = responseObject["text"] as? String {
            
            self.postText = postText
            
            print("===NAG=== self.postText = \(self.postText!)")

        }
        
        if let postDate = responseObject["date"] as? Int {
            self.postDate = postDate
            print("===NAG=== self.postDate = \(self.postDate!)")

        }
        
        if let postAuthorID = responseObject["from_id"] as? Int {
            self.postAuthorID = String(postAuthorID)
            print("===NAG=== self.postAuthorID = \(self.postAuthorID!)")

        }
        
        
        
        let commentsDict = responseObject["comments"] as! [String: Any]
        
        if let postComments = commentsDict["count"] as? Int {
            self.postComments = String(postComments)
            print("===NAG=== self.postComments = \(self.postComments!)")
            
        }

        let likesDict = responseObject["likes"] as! [String: Any]
        
        if let postLikes = likesDict["count"] as? Int {
            self.postLikes = String(postLikes)
            print("===NAG=== self.postLikes = \(self.postLikes!)")

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













