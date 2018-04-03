//
//  PostPhotoGallery.swift
//  SensEye
//
//  Created by Anton Novoselov on 26/12/2016.
//  Copyright © 2016 Anton Novoselov. All rights reserved.
//

import UIKit
import AlamofireImage

class PostPhotoGallery {
    
    // MARK: - PROPERTIES
    private static let _sharedGalleryManager = PostPhotoGallery()
    
    static var sharedGalleryManager: PostPhotoGallery {
        return _sharedGalleryManager
    }
    
    let marginSpace: CGFloat = 16
    
    var firstRowCount = 1
    var maxPhotos = 4
    var sharedManagerExists = false
    
    private init() {
        sharedManagerExists = true
    }
    
    // MARK: - GALLERY METHODS
    func clearGallery(forPost post: WallPost, fromCell postCell: FeedCell) {
        
        for imageView in postCell.galleryImageViews {
            imageView.image = nil
        }
        
        postCell.galleryFirstRowLeadingConstraint.constant = 0
        postCell.gallerySecondRowLeadingConstraint.constant = 0
        postCell.gallerySecondRowTopConstraint.constant = 0
        
        for heightOfImageView in postCell.photoHeights {
            heightOfImageView.constant = 0
        }
        
        for widthOfImageView in postCell.photoWidths {
            widthOfImageView.constant = 0
        }
    }
    
    func insertGallery(forPost post: WallPost, toCell postCell: FeedCell) {
        
        // === PART 1. CHECKINGS
        //  If post contains no photos - set all ImageViews height to 0 (collapsing all Gallery ImageViews), and return cell immediately
        
        var postAttachments = post.postAttachments
        
        if postAttachments.isEmpty {
            
            postCell.gallerySecondRowTopConstraint.constant = 0
            
            for heightOfImageView in postCell.photoHeights {
                heightOfImageView.constant = 0
            }
            
            return
        }
        
        //  Check of attachments array before start main loop. If occasionally, there's photo with width or height equals to 0 - remove this photo from attachments array

        var index = 0
        
        while index < postAttachments.count {
            
            var photoObject: Photo!
            
            if let albumAttachment = postAttachments[index] as? PhotoAlbum {
                photoObject = albumAttachment.albumThumbPhoto
                
            } else if let photoAttachment = postAttachments[index] as? Photo {
                photoObject = photoAttachment
            }
            
            if photoObject.width == 0 || photoObject.height == 0 {
                postAttachments.remove(at: 0)
                continue
            }
            
            index += 1
        }
        
        // === PART 2. CALCULATIONS OF MAXIMUM SIZES FOR SQUARE GALLERY IMAGEVIEWS
        //  Calculation of Gallery ImageViews Maximum Sizes (depending on count of photos)

        var maxRequiredSizeOfImageInFirstRow: CGFloat = 0
        var maxRequiredSizeOfImageInSecondRow: CGFloat = 0
        
        let maxAvailableSpaceToOperate = min(UIScreen.main.bounds.width - marginSpace, 1300)
        
        if postAttachments.count <= firstRowCount {
            // If we have only 1 photo - use only first row
            
            maxRequiredSizeOfImageInFirstRow = min(640, maxAvailableSpaceToOperate) // Limit to 640
            
        } else {
            // If we have more than 2 photos - use both rows of Gallery
            
            maxRequiredSizeOfImageInFirstRow = min(640, maxAvailableSpaceToOperate)

            maxRequiredSizeOfImageInSecondRow = (maxAvailableSpaceToOperate) / CGFloat(min(maxPhotos, postAttachments.count - firstRowCount))
            
            maxRequiredSizeOfImageInSecondRow = min(640, maxRequiredSizeOfImageInSecondRow) // Limit to 640
        }
        
        // === PART 3. LOOP THROUGH PHOTOS IN ATTACHMENTS ARRAY AND HANDLE EACH PHOTO
        
        index = 0
        
        var maxHeightFirstRow: CGFloat = 0
        var fullWidthFirstRow: CGFloat = 0
        var fullWidthSecondRow: CGFloat = 0
        
        // *********^^^^^^^ MAIN LOOP FOR STARTS HERE ^^^^^^^****************

        while index < min(maxPhotos, postAttachments.count) {
            
            var photoObject: Photo!

            if let albumAttachment = postAttachments[index] as? PhotoAlbum {
                if let photoAlbumThumb = albumAttachment.albumThumbPhoto {
                    photoObject = photoAlbumThumb
                }
                
            } else if let photoAttachment = postAttachments[index] as? Photo {
                photoObject = photoAttachment
            }
            
            // * 1. Calculating width and height of current photo, according to calculated maxSize of square ImageView. If there's portrait photo - currentHeight = maxSize, if album oriented - currentWidth = maxSize
            
            let ratio: CGFloat = CGFloat(photoObject.width) / CGFloat(photoObject.height)
            
            var heightOfCurrentPhoto: CGFloat = 0
            var widthOfCurrentPhoto: CGFloat = 0
            
            if ratio < 1 {
                // ** Portrait oriented photo
                
                if index < firstRowCount {
                    // First Row of Gallery
                    heightOfCurrentPhoto = maxRequiredSizeOfImageInFirstRow
                    
                    widthOfCurrentPhoto = heightOfCurrentPhoto * CGFloat(ratio)
                    fullWidthFirstRow += widthOfCurrentPhoto
                    
                } else {
                    // Second Row Gallery
                    heightOfCurrentPhoto = maxRequiredSizeOfImageInSecondRow
                    widthOfCurrentPhoto = heightOfCurrentPhoto * CGFloat(ratio)
                    
                    fullWidthSecondRow += widthOfCurrentPhoto
                }
                
            } else {
                // ** Landscape oriented photo
                if index < firstRowCount {
                    // First Row of Gallery
                    widthOfCurrentPhoto = maxRequiredSizeOfImageInFirstRow
                    fullWidthFirstRow += widthOfCurrentPhoto
                    
                } else {
                    // Second Row Gallery
                    widthOfCurrentPhoto = maxRequiredSizeOfImageInSecondRow
                    fullWidthSecondRow += widthOfCurrentPhoto
                }
                
                heightOfCurrentPhoto = widthOfCurrentPhoto / CGFloat(ratio)
            }
            
            // * 2. Calculating height of FirstRow to get know value for gallerySecondRowTopConstraint
            if heightOfCurrentPhoto > maxHeightFirstRow && index < firstRowCount {
                maxHeightFirstRow = heightOfCurrentPhoto
            }
            
            // * 3. Setting width and height constraints for current photo and setting frame
            let photoHightConstraint = postCell.photoHeights[index]
            let photoWidthConstraint = postCell.photoWidths[index]
            
            photoHightConstraint.constant = heightOfCurrentPhoto
            photoWidthConstraint.constant = widthOfCurrentPhoto
            
            let currentImageView = postCell.galleryImageViews[index]
            
            let currentImageViewOrigin = currentImageView.frame.origin
            
            currentImageView.frame = CGRect(x: currentImageViewOrigin.x, y: currentImageViewOrigin.y, width: widthOfCurrentPhoto, height: heightOfCurrentPhoto)
            
            // * 4. Loading and setting image
            var linkToNeededRes: String?
            var neededRes: PhotoResolution
            
            if index < firstRowCount {
                if maxRequiredSizeOfImageInFirstRow > 600 {
                    linkToNeededRes = photoObject.photo_807
                    neededRes = .res807
                } else {
                    linkToNeededRes = photoObject.photo_604
                    neededRes = .res604
                }
                
            } else {
                if maxRequiredSizeOfImageInSecondRow > 600 {
                    linkToNeededRes = photoObject.photo_807
                    neededRes = .res807
                    
                } else {
                    linkToNeededRes = photoObject.photo_604
                    neededRes = .res604
                }
            }
            
            // Looking for max resolution, if not found yet
            if linkToNeededRes == nil {
                
                var index = neededRes.rawValue - 1
                
                while index >= PhotoResolution.res75.rawValue {
                    let lessResKey = photoObject.keysResArray[index]
                    let lessResolution = photoObject.resolutionDictionary[lessResKey]
                    
                    if lessResolution != nil {
                        linkToNeededRes = lessResolution!
                        break
                    }
                    
                    index -= 1
                }
                
                if linkToNeededRes == nil {
                    linkToNeededRes = photoObject.maxRes
                }
            }
            
            let urlPhoto = URL(string: linkToNeededRes!)
            
            currentImageView.af_setImage(withURL: urlPhoto!)
            
            index += 1
        }
        // *********$$$$$$$$ MAIN LOOP FOR ENDS HERE $$$$$$$****************

        // === PART 4. LAST PREPARATIONS, SETTING GLOBAL GALLERY INSETS, COLLAPSING UNUSED IMAGEVIEWS
        //  Setting top constraint for second row

        postCell.gallerySecondRowTopConstraint.constant = maxHeightFirstRow + 10
        
        //  For unused Gallery Image Views - setting widhts and heights to 0. Collapsing unused imageviews.
        
        index = postAttachments.count
        
        while index < postCell.photoWidths.count {
            
            let photoHightConstraint = postCell.photoHeights[index]
            photoHightConstraint.constant = 0
            
            let photoWidthConstraint = postCell.photoWidths[index]
            photoWidthConstraint.constant = 0
            
            let unusedImageView = postCell.galleryImageViews[index]
            
            unusedImageView.frame = CGRect(x: unusedImageView.frame.origin.x, y: unusedImageView.frame.origin.y, width: 0, height: 0)
            
            index += 1
        }
        
        // Centering Gallery
        
        var indentsCountFirstRow: CGFloat
        var indentsCountSecondRow: CGFloat
        
        if postAttachments.count <= firstRowCount {
            indentsCountFirstRow = CGFloat(postAttachments.count - 1)
            postCell.gallerySecondRowLeadingConstraint.constant = 0
        
        } else {
            indentsCountFirstRow = CGFloat(firstRowCount - 1)
            indentsCountSecondRow = CGFloat(min(maxPhotos, postAttachments.count) - firstRowCount - 1)
            
            postCell.gallerySecondRowLeadingConstraint.constant = (UIScreen.main.bounds.width - marginSpace - 2 * indentsCountSecondRow - fullWidthSecondRow) / 2
            
        }
        
        postCell.galleryFirstRowLeadingConstraint.constant = (UIScreen.main.bounds.width - marginSpace - 2 * indentsCountFirstRow - fullWidthFirstRow) / 2
        
        postCell.layoutIfNeeded()
        
        // ADDING GESTURE RECOGNIZERS FOR GALLERY
        
        for photoImageView in postCell.galleryImageViews {
            photoImageView.isUserInteractionEnabled = true
            
            let tapGesture = UITapGestureRecognizer(target: postCell, action: #selector(postCell.actionGlryImageViewDidTap))
            
            photoImageView.addGestureRecognizer(tapGesture)
        }
    }
}



