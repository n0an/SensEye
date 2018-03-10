//
//  Comment.swift
//  SensEye
//
//  Created by Anton Novoselov on 04/01/2017.
//  Copyright © 2017 Anton Novoselov. All rights reserved.
//

import Foundation
import SwiftyJSON

class Comment: ServerObject {
    
    // MARK: - PROPERTIES
    var commentID: String!
    var commentText: String!
    var commentDate: Int!
    
    var postAuthorID: String!
    var postAuthor: User?
    var postGroupAuthor: Group?
    
    var commentLikesCount: Int = 0
    
    var isLikedByCurrentUser = false
    
    // MARK: - INITIALIZERS
    required init(responseObject: JSON) {
        
        self.commentID = String(responseObject["id"].intValue)
        
        if let postText = responseObject["text"].string {
            if postText.hasPrefix("[id") {
                self.commentText = refineAuthor(rawText: postText)
            } else {
                self.commentText = postText
            }
        }
        
        self.commentDate = responseObject["date"].intValue
        
        self.postAuthorID = String(responseObject["from_id"].intValue)
        
        self.commentLikesCount = responseObject["likes"]["count"].intValue
        
        let isLikedByCurrentUser = responseObject["likes"]["can_like"].intValue
        
        self.isLikedByCurrentUser = isLikedByCurrentUser == 0 ? true : false
        
    }
    
    // MARK: - HELPER METHODS
    func refineAuthor(rawText: String) -> String {
        var resultString = rawText
        
        let nsRawText = rawText as NSString
        
        let range1 = nsRawText.range(of: "|")
        let range2 = nsRawText.range(of: "],")
        
        let range = NSMakeRange(range1.location + 1, range2.location - range1.location - 1)
        
        let rawAuthor = nsRawText.substring(with: range)
        let finedAuthor = rawAuthor + ","
        let otherText = nsRawText.substring(from: range2.location + range2.length)
        
        resultString = finedAuthor + otherText
        
        return resultString
    }
}




// MARK: - Equatable protocol

extension Comment: Equatable { }

func ==(lhs: Comment, rhs: Comment) -> Bool {
    return lhs.commentID == rhs.commentID
}



