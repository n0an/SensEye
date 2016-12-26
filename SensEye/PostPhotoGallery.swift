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
    
    var tableViewWidth: CGFloat
    
    var firstRowCount = 1
    var maxPhotos = 4
    
    init(withTableViewWidth tableViewWidth: CGFloat) {
        
        self.tableViewWidth = tableViewWidth
        
    }
    
    func insertGallery(forPost post: WallPost, toCell postCell: FeedCell) {
        
        // === PART 1. CHECKINGS
        
        //  If post contains no photos - set all ImageViews height to 0 (collapsing all Gallery ImageViews), and return cell immediately
        
        if post.postAttachments.isEmpty {
            
            postCell.gallerySecondRowTopConstraint.constant = 0
            
            for heightOfImageView in postCell.photoHeights {
                heightOfImageView.constant = 0
            }
            
            return
            
        }
        
        // === PART 2. CALCULATIONS OF MAXIMUM SIZES FOR SQUARE GALLERY IMAGEVIEWS
        
        //  Calculation of Gallery ImageViews Maximum Sizes (depending on count of photos)

        var maxRequiredSizeOfImageInFirstRow: CGFloat = 0
        var maxRequiredSizeOfImageInSecondRow: CGFloat = 0
        
        var maxAvailableSpaceToOperate = min(self.tableViewWidth, 1300)
        

        
        if post.postAttachments.count <= firstRowCount {
            // If we have only 1 photo - use only first row
            
            maxRequiredSizeOfImageInFirstRow = maxAvailableSpaceToOperate
            
        } else {
            // If we have more than 2 photos - use both rows of Gallery
            
            maxRequiredSizeOfImageInFirstRow = maxAvailableSpaceToOperate

            maxRequiredSizeOfImageInSecondRow = maxAvailableSpaceToOperate / CGFloat(min(maxPhotos, post.postAttachments.count - firstRowCount))
            
            
        }
        
        
        // === PART 3. LOOP THROUGH PHOTOS IN ATTACHMENTS ARRAY AND HANDLE EACH PHOTO
        
        var index = 0
        
        var maxHeightFirstRow: CGFloat = 0
        var fullWidthFirstRow: CGFloat = 0
        var fullWidthSecondRow: CGFloat = 0
        
        while index < min(maxPhotos, post.postAttachments.count) {
            
            
            var photoObject: Photo!

            
            if let albumAttachment = post.postAttachments[index] as? PhotoAlbum {
                
                if let photoAlbumThumb = albumAttachment.albumThumbPhoto {
                    photoObject = photoAlbumThumb
                }
                
            } else if let photoAttachment = post.postAttachments[index] as? Photo {
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
            
            var linkToNeededRes: String
            
            
            if index < firstRowCount {
                
                if maxRequiredSizeOfImageInFirstRow > 600 {
                    linkToNeededRes = photoObject.photo_807!
                    
                } else {
                    linkToNeededRes = photoObject.photo_604!
                }
                
            } else {
                if maxRequiredSizeOfImageInSecondRow > 600 {
                    linkToNeededRes = photoObject.photo_807!
                    
                } else {
                    linkToNeededRes = photoObject.photo_604!
                }
            }
            
            
            let urlPhoto = URL(string: linkToNeededRes)
            
            currentImageView.af_setImage(withURL: urlPhoto!)
            
            

            
            index += 1
        }
        
        
        // === PART 4. LAST PREPARATIONS, SETTING GLOBAL GALLERY INSETS, COLLAPSING UNUSED IMAGEVIEWS

        //  Setting top constraint for second row

        postCell.gallerySecondRowTopConstraint.constant = maxHeightFirstRow + 10
        
        //  For unused Gallery Image Views - setting widhts and heights to 0. Collapsing unused imageviews.
        
        index = post.postAttachments.count
        
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
        
        if post.postAttachments.count <= firstRowCount {
            indentsCountFirstRow = CGFloat(post.postAttachments.count - 1)
            postCell.gallerySecondRowLeadingConstraint.constant = 0
        
        } else {
            indentsCountFirstRow = CGFloat(firstRowCount - 1)
            indentsCountSecondRow = CGFloat(min(maxPhotos, post.postAttachments.count) - firstRowCount - 1)
            
            postCell.gallerySecondRowLeadingConstraint.constant = (self.tableViewWidth - 2 * indentsCountSecondRow - fullWidthSecondRow) / 2
            
        }
        
        postCell.galleryFirstRowLeadingConstraint.constant = (self.tableViewWidth - 2 * indentsCountFirstRow - fullWidthFirstRow) / 2
        
        print("===NAG== postCell.galleryFirstRowLeadingConstraint.constant = \(postCell.galleryFirstRowLeadingConstraint.constant)")
        
        postCell.layoutIfNeeded()
        
        
        
    }
    
    
}



















