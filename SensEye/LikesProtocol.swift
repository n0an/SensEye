//
//  LikesProtocol.swift
//  SensEye
//
//  Created by Anton Novoselov on 02/04/2018.
//  Copyright © 2018 Anton Novoselov. All rights reserved.
//

import Foundation

protocol LikesProtocol {
    func isLiked(forItemType itemType: FeedItemsType, ownerID: String, itemID: String, completed: @escaping ([String: Any]?) -> Void)
    
    func addLike(forItemType itemType: FeedItemsType, ownerID: String, itemID: String, completed: @escaping LikeFeatureCompletion)
    
    func deleteLike(forItemType itemType: FeedItemsType, ownerID: String, itemID: String, completed: @escaping LikeFeatureCompletion)
}

extension LikesProtocol {
    func isLiked(forItemType itemType: FeedItemsType, ownerID: String, itemID: String, completed: @escaping ([String: Any]?) -> Void) {
        ServerManager.sharedManager.isLiked(forItemType: itemType, ownerID: ownerID, itemID: itemID, completed: completed)
    }
    
    func addLike(forItemType itemType: FeedItemsType, ownerID: String, itemID: String, completed: @escaping LikeFeatureCompletion) {
        ServerManager.sharedManager.addLike(forItemType: itemType, ownerID: ownerID, itemID: itemID, completed: completed)
        
    }
    
    func deleteLike(forItemType itemType: FeedItemsType, ownerID: String, itemID: String, completed: @escaping LikeFeatureCompletion) {
        ServerManager.sharedManager.deleteLike(forItemType: itemType, ownerID: ownerID, itemID: itemID, completed: completed)
    }
}
