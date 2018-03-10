//
//  WallPost.swift
//  SensEye
//
//  Created by Anton Novoselov on 26/12/2016.
//  Copyright © 2016 Anton Novoselov. All rights reserved.
//

import Foundation
import SwiftyJSON

class WallPost: ServerObject {
    
    // MARK: - PROPERTIES
    var postID: String!
    var postText: String!
    var postDate: Int!
    
    var postAuthorID: String!
    var postAuthor: User?
    var postGroupAuthor: Group?
    
    var postAttachments: [Any]?
    
    var postComments: String!
    var postLikesCount: Int = 0
    
    var isLikedByCurrentUser = false
    
    // MARK: - INITIALIZERS
    required init(responseObject: JSON) {
        
        self.postID = String(responseObject["id"].intValue)
        
//        if let postID = responseObject["id"] as? Int {
//            self.postID = String(postID)
//        }
        
        self.postText = responseObject["text"].stringValue
        
//        if let postText = responseObject["text"] as? String {
//            self.postText = postText
//        }
        
        self.postDate = responseObject["date"].intValue
        
//        if let postDate = responseObject["date"] as? Int {
//            self.postDate = postDate
//        }
        
        self.postAuthorID = String(responseObject["from_id"].intValue)
        
//        if let postAuthorID = responseObject["from_id"] as? Int {
//            self.postAuthorID = String(postAuthorID)
//        }
        
//        let commentsDict = responseObject["comments"] as! [String: Any]
        
        self.postComments = String(responseObject["comments"]["count"].intValue)
        
//        if let postComments = commentsDict["count"] as? Int {
//            self.postComments = String(postComments)
//        }

//        let likesDict = responseObject["likes"] as! [String: Any]
        
        self.postLikesCount = responseObject["likes"]["count"].intValue
        
//        if let postLikesCount = likesDict["count"] as? Int {
//            self.postLikesCount = postLikesCount
//        }
        
        let isLikedByCurrentUser = responseObject["likes"]["can_like"].intValue
        
        self.isLikedByCurrentUser = isLikedByCurrentUser == 0 ? true : false
        
//        if let isLikedByCurrentUser = likesDict["can_like"] as? Int {
//            self.isLikedByCurrentUser = isLikedByCurrentUser == 0 ? true : false
//        }
        
        
        // Attachments
//        guard let attachments = responseObject["attachments"] as? [Any] else {
//            return
//        }
        
        let attachments = responseObject["attachments"].arrayValue
        
        
        var attachmentsArray = [Any]()
        
        for item in attachments {
//            let attachmentItem = item as! [String: Any]
            let attachmentType = item["type"].stringValue
            
            if attachmentType == "photo" {
                // Parse Photo Attachment
                let attachmentDict = item["photo"]
                
                let photoAttachment = Photo(responseObject: attachmentDict)
                
                attachmentsArray.append(photoAttachment)
                
            } else if attachmentType == "album" {
                // Parse Album Attachment
                let attachmentDict = item["album"]
                
                let albumAttachment = PhotoAlbum(responseObject: attachmentDict)
                
                attachmentsArray.append(albumAttachment)
            }
        }
        
        self.postAttachments = attachmentsArray
        
        
    }
}



// MARK: - Equatable protocol

extension WallPost: Equatable { }

func ==(lhs: WallPost, rhs: WallPost) -> Bool {
    return lhs.postID == rhs.postID
}





