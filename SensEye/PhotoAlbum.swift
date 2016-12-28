//
//  PhotoAlbum.swift
//  SensEye
//
//  Created by Anton Novoselov on 26/12/2016.
//  Copyright © 2016 Anton Novoselov. All rights reserved.
//

import Foundation

class PhotoAlbum {
    
    var albumID: String!
    var ownerID: String!
    var albumTitle: String!
    var albumDescription: String!
    
    var albumSize: Int!
    
    var albumThumbID: String?
    
    var albumThumbImageURL: String?
    
    var albumThumbPhoto: Photo?
    
    
    init(responseObject: [String: Any]) {
        
        
        if let albumID = responseObject["id"] as? String {
            self.albumID = albumID
        } else if let albumID = responseObject["id"] as? Int {
            self.albumID = String(albumID)
        }
        
        if let ownderID = responseObject["owner_id"] as? Int {
            self.ownerID = String(ownderID)
        }
        
        if let albumTitle = responseObject["title"] as? String {
            self.albumTitle = albumTitle
        }
        
        if let albumDescription = responseObject["description"] as? String {
            self.albumDescription = albumDescription
        }
        
        if let albumSize = responseObject["size"] as? Int {
            self.albumSize = albumSize
        }
        
        if let albumThumbID = responseObject["thumb_id"] as? Int {
            self.albumThumbID = String(albumThumbID)
        }
        
        if let albumThumbImageURL = responseObject["thumb_src"] as? String {
            self.albumThumbImageURL = albumThumbImageURL
        }
        
        
        
        if let thumbDict = responseObject["thumb"] as? [String: Any] {
            
            let albumThumbPhoto = Photo(responseObject: thumbDict)
            
            self.albumThumbPhoto = albumThumbPhoto
            
        }
        
        
        
        
        
    }
    
}






















