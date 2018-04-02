//
//  PhotosProtocol.swift
//  SensEye
//
//  Created by Anton Novoselov on 02/04/2018.
//  Copyright © 2018 Anton Novoselov. All rights reserved.
//

import Foundation

protocol PhotosProtocol {
    
    func getPhotos(forAlbumID albumID: String, ownerID: String, offset: Int?, count: Int?, completed: @escaping DownloadComplete)
    
    func getPhotoAlbums(forGroupID groupID: String, completed: @escaping DownloadComplete)
    
    
}

extension PhotosProtocol {
    func getPhotos(forAlbumID albumID: String, ownerID: String, offset: Int? = nil, count: Int? = nil, completed: @escaping DownloadComplete) {
        ServerManager.sharedManager.getPhotos(forAlbumID: albumID, ownerID: ownerID, offset: offset, count: count, completed: completed)
    }
    
    func getPhotoAlbums(forGroupID groupID: String, completed: @escaping DownloadComplete) {
        ServerManager.sharedManager.getPhotoAlbums(forGroupID: groupID, completed: completed)
    }
    
}
