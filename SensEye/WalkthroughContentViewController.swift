//
//  WalkthroughContentViewController.swift
//  FoodPin
//
//  Created by Simon Ng on 18/8/2016.
//  Copyright © 2016 AppCoda. All rights reserved.
//

import UIKit

class WalkthroughContentViewController: UIViewController {
    
    @IBOutlet var headingLabel: UILabel!
    @IBOutlet var contentLabel: UILabel!
    @IBOutlet var contentImageView: UIImageView!
    @IBOutlet var pageControl: UIPageControl!
    @IBOutlet var forwardButton: UIButton!
    
    var index = 0
    var heading = ""
    var imageFile = ""
    var content = ""
    var totalAlbums: Int!
    
    var album: PhotoAlbum!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pageControl.currentPage = index
        
        updateUI()
        
        
    }
    
    func updateUI() {
        
        contentLabel.text = self.album.albumTitle
        pageControl.numberOfPages = totalAlbums
        
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
            
            
            
            self.contentImageView.af_setImage(withURL: urlPhoto!)
            
            
        }
        
        
        
    }
    
    
    
    
    // MARK: - IBAction Methods
    
    @IBAction func nextButtonTapped(sender: UIButton) {
        
        let pageViewController = parent as! WalkthroughPageViewController
        pageViewController.forward(index: index)
    }
}














