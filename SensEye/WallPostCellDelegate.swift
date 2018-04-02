//
//  WallPostCellDelegate.swift
//  SensEye
//
//  Created by Anton Novoselov on 22/03/2018.
//  Copyright © 2018 Anton Novoselov. All rights reserved.
//

import UIKit
import IDMPhotoBrowser
import Jelly

class WallPostCellDelegate: NSObject, FeedCellDelegate, PhotosProtocol {
    
    weak var vc: GeneralFeedViewController?
    
    fileprivate var jellyAnimator: JellyAnimator?
    
    
    init(vc: GeneralFeedViewController) {
        self.vc = vc
    }
    
    func feedCell(_ feedCell: FeedCell, didTapGalleryImageWith post: WallPost, withPhotoIndex index: Int) {
        if let photosArray = post.postAttachments as? [Photo] {
            performJellyTransition(withPhotos: photosArray, indexOfPhoto: index)
            
        } else if let albumAttach = post.postAttachments[0] as? PhotoAlbum {
            
            getPhotos(forAlbumID: albumAttach.albumID, ownerID: albumAttach.ownerID, completed: { (result) in
                
                let photos = result as! [Photo]
                
                // Calculating index of clicked photo in album
                let indexOfClickedPhotoInAlbum = photos.index(of: albumAttach.albumThumbPhoto!)
                
                self.performJellyTransition(withPhotos: photos, indexOfPhoto: indexOfClickedPhotoInAlbum ?? index)
            })
        }
    }
    
    func feedCellNeedProvideAuthorization(_ feedCell: UITableViewCell) {
        UserDefaults.standard.set(false, forKey: KEY_VK_USERCANCELAUTH)
        UserDefaults.standard.synchronize()
        
        guard let vc = vc else { return }
        GeneralHelper.sharedHelper.showVKAuthorizeActionSheetOnViewController(viewController: vc) { (selected) in
            
            if selected == true {
                self.vc?.toAuthorize()
            }
        }
    }
    
    func feedCell(_ feedCell: FeedCell, didTapCommentFor post: WallPost) {
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
    
    
}

extension WallPostCellDelegate: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if (self.vc?.isKind(of: FeedViewController.self))! {
            return indexPath
        } else {
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let cell = tableView.cellForRow(at: indexPath) as! FeedCell
        
        vc?.performSegue(withIdentifier: Storyboard.seguePostVC, sender: cell)
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        if (self.vc?.isKind(of: FeedViewController.self))! {
            return Storyboard.rowHeightFeed
        } else {
            if indexPath.section == TableViewSectionType.post.rawValue {
                return Storyboard.rowHeightFeed
            } else {
                return Storyboard.rowHeightCommentCell
            }
        }
        
    }
}

