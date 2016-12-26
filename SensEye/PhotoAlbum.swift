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
    var albumTitle: String!
    var albumDescription: String!
    var albumSize: Int!
    var albumThumbImageURL: String?
    
    var albumThumbPhoto: Photo?
    
    
    init(responseObject: [String: Any]) {
        
        
        if let albumID = responseObject["albumID"] as? Int {
            self.albumID = String(albumID)
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
        
        if let thumbDict = responseObject["thumb"] as? [String: Any] {
            
            let albumThumbPhoto = Photo(responseObject: thumbDict)
            
            self.albumThumbPhoto = albumThumbPhoto
            
        }
        
        
        
        
        
    }
    
}






















