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
        
        var albumURLString: String?
        
        
        if let albumThumbImageURLStr = album.albumThumbPhoto?.photo_604 {
            albumURLString = albumThumbImageURLStr
            
        } else if let albumThumbImageURLStr = album.albumThumbImageURL {
            albumURLString = albumThumbImageURLStr
        }
        
        if let albumURLString = albumURLString {
            
            let imageURL = URL(string: albumURLString)
            
            albumThumbImageView.af_setImage(withURL: imageURL!)
        }
        
        
        
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.layer.cornerRadius = 10.0
        self.clipsToBounds = true
        
    }
    
    
    
    
    
    
    
    
}
