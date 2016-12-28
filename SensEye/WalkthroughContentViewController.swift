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
    
    var album: PhotoAlbum! {
        didSet {
            updateUI()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        headingLabel.text = heading
//        contentLabel.text = content
//        contentImageView.image = UIImage(named: imageFile)
        pageControl.currentPage = index
        
        switch index {
        case 0...1: forwardButton.setTitle("NEXT", for: .normal)
        case 2: forwardButton.setTitle("DONE", for: .normal)
        default: break
        }
        
    }
    
    func updateUI() {
        
//        headingLabel.text = self.album.albumTitle
//        contentLabel.text = content
        
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
        
//        switch index {
//        case 0...1: // Next Button
//            let pageViewController = parent as! WalkthroughPageViewController
//            pageViewController.forward(index: index)
//            
//        case 2: // Done Button
//            UserDefaults.standard.set(true, forKey: "hasViewedWalkthrough")
//            
//            // Add Quick Actions
//            if traitCollection.forceTouchCapability == UIForceTouchCapability.available {
//                let bundleIdentifier = Bundle.main.bundleIdentifier
//                let shortcutItem1 = UIApplicationShortcutItem(type: "\(bundleIdentifier).OpenFavorites", localizedTitle: "Show Favorites", localizedSubtitle: nil, icon: UIApplicationShortcutIcon(templateImageName: "favorite-shortcut"), userInfo: nil)
//                let shortcutItem2 = UIApplicationShortcutItem(type: "\(bundleIdentifier).OpenDiscover", localizedTitle: "Discover Restaurants", localizedSubtitle: nil, icon: UIApplicationShortcutIcon(templateImageName: "discover-shortcut"), userInfo: nil)
//                let shortcutItem3 = UIApplicationShortcutItem(type: "\(bundleIdentifier).NewRestaurant", localizedTitle: "New Restaurant", localizedSubtitle: nil, icon: UIApplicationShortcutIcon(type: .add), userInfo: nil)
//                UIApplication.shared.shortcutItems = [shortcutItem1, shortcutItem2, shortcutItem3]
//            }
//            
//            dismiss(animated: true, completion: nil)
//            
//        default: break
//            
//        }
    }
}
