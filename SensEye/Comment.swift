//
//  Comment.swift
//  SensEye
//
//  Created by Anton Novoselov on 04/01/2017.
//  Copyright © 2017 Anton Novoselov. All rights reserved.
//

import Foundation


class Comment: ServerObject {
    
    var commentID: String!
    var commentText: String!
    var commentDate: Int!
    
    var postAuthorID: String!
    var postAuthor: User?
    var postGroupAuthor: Group?
    
    var postComments: String!
    var commentLikesCount: Int = 0
    
    var isLikedByCurrentUser = false
    
    required init(responseObject: [String: Any]) {
        
        if let commentID = responseObject["id"] as? Int {
            
            self.commentID = String(commentID)
        }
        
        if let postText = responseObject["text"] as? String {
            
            self.commentText = postText
            
        }
        
        if let postDate = responseObject["date"] as? Int {
            self.commentDate = postDate
            
        }
        
        if let postAuthorID = responseObject["from_id"] as? Int {
            self.postAuthorID = String(postAuthorID)
            
        }
        
        let likesDict = responseObject["likes"] as! [String: Any]
        
        if let commentLikesCount = likesDict["count"] as? Int {
            self.commentLikesCount = commentLikesCount
            
        }
        
        
    }
    
}


// MARK: - Like/Dislike feature
extension Comment {
    
    func toLike() {
        
        if self.isLikedByCurrentUser == false {
            
            commentLikesCount += 1
            
            self.isLikedByCurrentUser = true
        }
    }
    
    func toDislike() {
        
        if self.isLikedByCurrentUser == true {
            
            commentLikesCount -= 1
            
            self.isLikedByCurrentUser = false
        }
    }
}


// MARK: - Equatable protocol

extension Comment: Equatable { }

func ==(lhs: Comment, rhs: Comment) -> Bool {
    return lhs.commentID == rhs.commentID
}















