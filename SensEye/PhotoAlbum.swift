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
        
        self.albumTitle = responseObject["title"].stringValue
        
        self.albumDescription = responseObject["description"].stringValue

        self.albumSize = responseObject["size"].intValue

        self.albumThumbID = String(responseObject["thumb_id"].intValue)

        self.albumThumbImageURL = responseObject["thumb_src"].stringValue

        
        if responseObject["thumb"].dictionary != nil {
            let albumThumbPhoto = Photo(responseObject: responseObject["thumb"])
            self.albumThumbPhoto = albumThumbPhoto
        }
        
//        let albumThumbPhoto = Photo(responseObject: responseObject["thumb"])
//        self.albumThumbPhoto = albumThumbPhoto
        
//        if let thumbDict = responseObject["thumb"] {
//            let albumThumbPhoto = Photo(responseObject: thumbDict)
//            self.albumThumbPhoto = albumThumbPhoto
//        }
    }
}


