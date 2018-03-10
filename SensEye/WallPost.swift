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
    
    var postAttachments: [Any]
    
    var postComments: String!
    var postLikesCount: Int = 0
    
    var isLikedByCurrentUser = false
    
    // MARK: - INITIALIZERS
    required init(responseObject: JSON) {
        
        self.postID = String(responseObject["id"].intValue)
        self.postText = responseObject["text"].stringValue
        self.postDate = responseObject["date"].intValue
        self.postAuthorID = String(responseObject["from_id"].intValue)
        self.postComments = String(responseObject["comments"]["count"].intValue)
        self.postLikesCount = responseObject["likes"]["count"].intValue
        
        let isLikedByCurrentUser = responseObject["likes"]["can_like"].intValue
        self.isLikedByCurrentUser = isLikedByCurrentUser == 0 ? true : false
        
        let attachments = responseObject["attachments"].arrayValue
        
        var attachmentsArray = [Any]()
        
        for item in attachments {

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





