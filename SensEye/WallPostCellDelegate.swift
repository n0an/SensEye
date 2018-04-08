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
        
        let commentComposerVC = UIStoryboard.commentComposerVC()
        
        let navVC = UINavigationController(rootViewController: commentComposerVC!)
        
        commentComposerVC?.delegate = self.vc as? CommentComposerViewControllerDelegate
        
        commentComposerVC?.wallPost = post
        
        self.vc?.present(navVC, animated: true)

    }
    
    
    func performJellyTransition(withPhotos photosArray: [Photo], indexOfPhoto: Int) {
        
        var urlsArray: [URL] = []
        
        for photo in photosArray {
            var linkToNeededRes: String!
            
            if vc?.traitCollection.horizontalSizeClass == .regular && vc?.traitCollection.verticalSizeClass == .regular {
                linkToNeededRes = photo.maxRes
                
            } else {
                if photo.photo_1280 != "" {
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
        
        browser?.displayDoneButton      = false
        browser?.displayActionButton    = false
        browser?.useWhiteBackgroundColor = true
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
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let cell = tableView.cellForRow(at: indexPath) as! FeedCell
        let postVC = UIStoryboard.postVC()
        postVC?.wallPost = cell.wallPost
        postVC?.backgroundImage = cell.postImageView.image
        vc?.present(postVC!, animated: true)
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
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
     
        guard let vc = self.vc as? PostViewController else {
            return
        }
        
        vc.updateHeaderView()
        
        let offsetY = scrollView.contentOffset.y
        let adjustment: CGFloat = 100
        
        if (-offsetY) > (Storyboard.tableHeaderHeight + adjustment) {
            vc.dismiss(animated: true, completion: nil)
        }
        
        if (-offsetY) > (Storyboard.tableHeaderHeight) {
            vc.headerView.pullDownToCloseLabel.isHidden = false
        } else {
            vc.headerView.pullDownToCloseLabel.isHidden = true
        }
    }
}

