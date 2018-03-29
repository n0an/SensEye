//
//  FeedCellDelegate.swift
//  SensEye
//
//  Created by Anton Novoselov on 23/03/2018.
//  Copyright © 2018 Anton Novoselov. All rights reserved.
//

import UIKit

protocol FeedCellDelegate: AnyObject {
    
    func feedCell(_ feedCell: FeedCell, didTapGalleryImageWith post: WallPost, withPhotoIndex index: Int)
    
    func feedCellNeedProvideAuthorization(_ feedCell: UITableViewCell)
    
    func feedCell(_ feedCell: FeedCell, didTapCommentFor post: WallPost)
}
