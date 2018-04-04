//
//  Constants.swift
//  SensEye
//
//  Created by Anton Novoselov on 26/12/2016.
//  Copyright © 2016 Anton Novoselov. All rights reserved.
//

import UIKit

// MARK: - APP SETTINGS
public let APP_FIRST_RUN = "appFirstRun"

// MARK: - ===== TYPE ALIASES ====
typealias DownloadComplete = ([Any]) -> Void
typealias AuthoizationComplete = (User) -> Void
typealias LikeFeatureCompletion = (Bool, [String: Any]?) -> Void

typealias ProjectProtocol = AuthorizationProtocol & FeedProtocol & LikesProtocol & PhotosProtocol

// MARK: - ===== UI SETTINGS ====
let mainShadowColor         = UIColor(netHex: 0x787878)
var shadowColor             = mainShadowColor

var shadowWidth: CGFloat    = 1.0
var shadowHeight: CGFloat   = 2.0
var shadowOpacity: Float    = 0.6
var shadowRadius: CGFloat   = 4.0

let mainThemeColor          = UIColor(netHex: 0xe2e2e2)
let mainTintColor           = UIColor(red: 10/255, green: 80/255, blue: 80/255, alpha: 1)

let cellSelectionColor      = UIColor(white: 1.0, alpha: 0.2)

// MARK: - ===== VK CONSTANTS =====

public let groupID                  = "-55347641"
let postsInRequest      = 10
let commentsInRequest   = 10

public let KEY_VK_DIDAUTH           = "vkAuth"
public let KEY_VK_USERCANCELAUTH    = "vkUserCancelAuth"
public let KEY_VK_TOKEN             = "vkAuthToken"

public let URL_BASE                 = "https://api.vk.com/method"
public let URL_WALL_FEED            = "/wall.get"
public let URL_PHOTOS               = "/photos.get"
public let URL_PHOTO_ALBUMS         = "/photos.getAlbums"
public let URL_COMMENTS             = "/wall.getComments"
public let URL_CREATE_COMMENT       = "/wall.createComment"
public let URL_USERS                = "/users.get"

public let URL_LIKES_ADD            = "/likes.add"
public let URL_LIKES_DELETE         = "/likes.delete"
public let URL_ISLIKED              = "/likes.isLiked"

public enum URL_PARAMS: String {
    case OWNER_ID       = "owner_id"
    case COUNT          = "count"
    case OFFSET         = "offset"
    case EXTENDED       = "extended"
    
    case ALBUM_ID       = "album_id"
    case NEED_COVERS    = "need_covers"
    
    case POST_ID        = "post_id"
    case NEED_LIKES     = "need_likes"
    
    case USER_IDS       = "user_ids"
    case USER_FIELDS    = "fields"
    
    case ITEM_TYPE      = "type"
    case ITEM_ID        = "item_id"
    
    case MESSAGE        = "message"
    
    case ACCESS_TOKEN   = "access_token"
    case LANG           = "lang"
    case REV            = "rev"
    
    case VER            = "v"
}


// MARK: - ==== CAMERA SETTINGS ===
let kMAXDURATION: Double    = 20.0


// MARK: - ==== CHAT SETTINGS ===
public let kNUMBEROFMESSAGES = 40

public let KEY_CHAT_USER        = "chatCurrentUser"
public let KEY_CHAT_OF_USER     = "chatForCurrentUser"

// MARK: - ==== STORYBOARD CONSTANTS ===
let MAIN_STORYBOARD = "Main"

// ViewControllers
let VC_FEED = "FeedViewController"
let VC_POST = "PostViewController"
let VC_COMMENTCOMPOSER = "CommentComposerViewController"
let VC_GALLERY = "LandscapeViewController"

let VC_LOGIN = "LoginViewController"
let VC_SIGNUP = "SignUpViewController"
let VC_RESETPASSWD = "ResetPasswordViewController"
let VC_RECENT = "RecentViewController"
let VC_CHAT = "ChatViewController"

let VC_ABOUT = "AboutTableViewController"

public enum TabBarIndex: Int {
    case gallery   = 0
    case about
    case wallFeed
    case chat
}

enum AboutScreenTableViewSection: Int {
    case connections = 0
    case socNet
    case info
}

public enum Storyboard {
    static let cellIdFeed       = "FeedCell"
    static let cellIdComment    = "CommentCell"
    
    static let cellIdChat       = "ChatCell"
    
    static let cellIdSocNet     = "AboutCellSocnet"
    static let cellIdInfo       = "AboutCellInfo"
    
    static let rowHeightFeed: CGFloat           = 370.0
    static let rowHeightCommentCell: CGFloat    = 100
    
    static let tableHeaderHeight: CGFloat       = 100
    static let tableHeaderCutAway: CGFloat      = 50
    
    static let rowHeightInfo: CGFloat           = 200
}

public enum TableViewSectionType: Int {
    case post
    case comment
}

