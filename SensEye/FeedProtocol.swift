//
//  FeedProtocol.swift
//  SensEye
//
//  Created by Anton Novoselov on 27/03/2018.
//  Copyright © 2018 Anton Novoselov. All rights reserved.
//

import Foundation

enum FeedItemsType: String {
    case post = "post"
    case comment = "comment"
}

protocol FeedProtocol {
    func getFeed(forType feedType: FeedItemsType, ownerID: String, postID: String?, offset: Int, count: Int, completed: @escaping DownloadComplete)
    
    func createComment(ownerID: String, postID: String, message: String, completed: @escaping (Bool) -> Void)
}

extension FeedProtocol {
    
    func getFeed(forType feedType: FeedItemsType, ownerID: String, postID: String? = nil, offset: Int, count: Int, completed: @escaping DownloadComplete) {
        ServerManager.sharedManager.getFeed(forType: feedType, ownerID: ownerID, postID: postID, offset: offset, count: count, completed: completed)
    }
    
    func createComment(ownerID: String, postID: String, message: String, completed: @escaping (Bool) -> Void) {
        ServerManager.sharedManager.createComment(ownerID: ownerID, postID: postID, message: message, completed: completed)
    }
}
