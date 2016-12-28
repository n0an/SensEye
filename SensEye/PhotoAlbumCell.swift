//
//  PhotoAlbumCell.swift
//  SensEye
//
//  Created by Anton Novoselov on 28/12/2016.
//  Copyright © 2016 Anton Novoselov. All rights reserved.
//

import UIKit
import AlamofireImage

class PhotoAlbumCell: UICollectionViewCell {
    
    // MARK: - OUTLETS
    
    @IBOutlet weak var albumThumbImageView: UIImageView!
    @IBOutlet weak var albumTitle: UILabel!
    
    var album: PhotoAlbum! {
        didSet {
            updateUI()
        }
    }
    
    func updateUI() {
        
        albumTitle.text = self.album.albumTitle
        
        ServerManager.sharedManager.getPhotos(forAlbumID: album.albumID, ownerID: groupID, offset: 0, count: 1) { (result) in
            
            guard let photos = result as? [Photo] else { return }
            
            guard photos.count > 0 else { return }
            
            let firstPhotoOfAlbum = photos.first
            
            var linkToNeededRes = firstPhotoOfAlbum?.photo_604
            let neededRes: PhotoResolution = .res604
            
            // Looking for max resolution, if not found yet
            if linkToNeededRes == nil {
                
                var index = neededRes.rawValue - 1
                
                while index >= PhotoResolution.res75.rawValue {
                    
                    let lessResKey = firstPhotoOfAlbum?.keysResArray[index]
                    
                    let lessResolution = firstPhotoOfAlbum?.resolutionDictionary[lessResKey!]
                    
                    if lessResolution != nil {
                        linkToNeededRes = lessResolution!
                        break
                    }
                    
                    index -= 1
                }
                
                if linkToNeededRes == nil {
                    linkToNeededRes = firstPhotoOfAlbum?.maxRes
                }
                
            }

            let urlPhoto = URL(string: linkToNeededRes!)

            self.albumThumbImageView.af_setImage(withURL: urlPhoto!)

            
        }
        
        
        
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.layer.cornerRadius = 10.0
        self.clipsToBounds = true
        
    }
    
    
    
    
    
    
    
    
}
