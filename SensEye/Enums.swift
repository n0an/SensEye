//
//  Enums.swift
//  SensEye
//
//  Created by Anton Novoselov on 02/04/2018.
//  Copyright © 2018 Anton Novoselov. All rights reserved.
//

import UIKit

public enum TabBarIndex: Int {
    case wallFeed   = 0
    case gallery
    case chat
    case about
}

public enum Storyboard {
    static let cellIdFeed               = "FeedCell"
    static let cellIdComment            = "CommentCell"
    
    static let rowHeightFeed: CGFloat           = 370.0
    static let rowHeightCommentCell: CGFloat    = 100
    
    static let seguePostVC              = "showPost"
    static let segueCommentComposer     = "ShowCommentComposer"
    
    
    static let tableHeaderHeight: CGFloat       = 100
    static let tableHeaderCutAway: CGFloat      = 50
}

public enum TableViewSectionType: Int {
    case post
    case comment
}
