//
//  CellDelegate.swift
//  SensEye
//
//  Created by Anton Novoselov on 22/03/2018.
//  Copyright © 2018 Anton Novoselov. All rights reserved.
//

import UIKit
import IDMPhotoBrowser
import Jelly

class CellDelegate: FeedCellDelegate {
    
    weak var vc: FeedViewController?
    
    fileprivate var jellyAnimator: JellyAnimator?

    
    init(vc: FeedViewController) {
        self.vc = vc
    }
    
    func provideAuthorization() {
        
        UserDefaults.standard.set(false, forKey: KEY_VK_USERCANCELAUTH)
        UserDefaults.standard.synchronize()
        
        guard let vc = vc else { return }
        GeneralHelper.sharedHelper.showVKAuthorizeActionSheetOnViewController(viewController: vc) { (selected) in
            
            if selected == true {
                self.vc?.toAuthorize()
            }
        }
    }
    
    func commentDidTap(post: WallPost) {
        vc?.performSegue(withIdentifier: Storyboard.segueCommentComposer, sender: post)
    }
    
    func performJellyTransition(withPhotos photosArray: [Photo], indexOfPhoto: Int) {
        
        var urlsArray: [URL] = []
        
        for photo in photosArray {
            var linkToNeededRes: String!
            
            if vc?.traitCollection.horizontalSizeClass == .regular && vc?.traitCollection.verticalSizeClass == .regular {
                linkToNeededRes = photo.maxRes
                
            } else {
                if photo.photo_1280 != nil {
                    linkToNeededRes = photo.photo_1280
                } else {
                    linkToNeededRes = photo.maxRes
                }
            }
            
            let imageURL = URL(string: linkToNeededRes)
            urlsArray.append(imageURL!)
        }
        
        let photos = IDMPhoto.photos(withURLs: urlsArray)
        
        let browser = IDMPhotoBrowser(photos: photos)
        
        browser?.displayDoneButton      = true
        browser?.displayActionButton    = false
        browser?.doneButtonImage        = UIImage(named: "CloseButton")
        browser?.setInitialPageIndex(UInt(indexOfPhoto))
        
        let customBlurFadeInPresentation = JellyFadeInPresentation(dismissCurve: .easeInEaseOut,
                                                                   presentationCurve: .easeInEaseOut,
                                                                   cornerRadius: 0,
                                                                   backgroundStyle: .blur(effectStyle: .light),
                                                                   duration: .normal,
                                                                   widthForViewController: .fullscreen,
                                                                   heightForViewController: .fullscreen)
        
        
        self.jellyAnimator = JellyAnimator(presentation: customBlurFadeInPresentation)
        self.jellyAnimator?.prepare(viewController: browser!)
        self.vc?.present(browser!, animated: true, completion: nil)
    }
    
    func galleryImageViewDidTap(wallPost: WallPost, clickedPhotoIndex: Int) {
        
        if let photosArray = wallPost.postAttachments as? [Photo] {
            performJellyTransition(withPhotos: photosArray, indexOfPhoto: clickedPhotoIndex)
            
        } else if let albumAttach = wallPost.postAttachments[0] as? PhotoAlbum {
            
            ServerManager.sharedManager.getPhotos(forAlbumID: albumAttach.albumID, ownerID: albumAttach.ownerID, completed: { (result) in
                
                let photos = result as! [Photo]
                
                // Calculating index of clicked photo in album
                let indexOfClickedPhotoInAlbum = photos.index(of: albumAttach.albumThumbPhoto!)
                
                self.performJellyTransition(withPhotos: photos, indexOfPhoto: indexOfClickedPhotoInAlbum ?? clickedPhotoIndex)
            })
        }
    }
    
    
}
