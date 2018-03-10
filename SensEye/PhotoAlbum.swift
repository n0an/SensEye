//
//  PhotoAlbum.swift
//  SensEye
//
//  Created by Anton Novoselov on 26/12/2016.
//  Copyright © 2016 Anton Novoselov. All rights reserved.
//

import Foundation
import SwiftyJSON

class PhotoAlbum {
    
    // MARK: - PROPERTIES
    var albumID: String!
    var ownerID: String!
    var albumTitle: String!
    var albumDescription: String!
    
    var albumSize: Int!
    var albumThumbID: String?
    var albumThumbImageURL: String?
    
    var albumThumbPhoto: Photo?
    
    // MARK: - INITIALIZERS
    init(responseObject: JSON) {
        
        if let albumID = responseObject["id"].string {
            self.albumID = albumID
        } else if let albumID = responseObject["id"].int {
            self.albumID = String(albumID)
        }
        
        self.ownerID = String(responseObject["owner_id"].intValue)
        
//        if let ownderID = responseObject["owner_id"] as? Int {
//            self.ownerID = String(ownderID)
//        }
        
        self.albumTitle = responseObject["title"].stringValue
        
//        if let albumTitle = responseObject["title"] as? String {
//            self.albumTitle = albumTitle
//        }
        
        
        self.albumDescription = responseObject["description"].stringValue

        
//        if let albumDescription = responseObject["description"] as? String {
//            self.albumDescription = albumDescription
//        }
        
        self.albumSize = responseObject["size"].intValue

        
//        if let albumSize = responseObject["size"] as? Int {
//            self.albumSize = albumSize
//        }

        self.albumThumbID = String(responseObject["thumb_id"].intValue)

        
//        if let albumThumbID = responseObject["thumb_id"] as? Int {
//            self.albumThumbID = String(albumThumbID)
//        }
        
        self.albumThumbImageURL = responseObject["thumb_src"].stringValue

        
//        if let albumThumbImageURL = responseObject["thumb_src"] as? String {
//            self.albumThumbImageURL = albumThumbImageURL
//        }
        
        
        let albumThumbPhoto = Photo(responseObject: responseObject["thumb"])
        self.albumThumbPhoto = albumThumbPhoto
        
//        if let thumbDict = responseObject["thumb"] {
//            let albumThumbPhoto = Photo(responseObject: thumbDict)
//            self.albumThumbPhoto = albumThumbPhoto
//        }
    }
}


