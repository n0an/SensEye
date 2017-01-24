//
//  Constants.swift
//  SensEye
//
//  Created by Anton Novoselov on 26/12/2016.
//  Copyright © 2016 Anton Novoselov. All rights reserved.
//

import UIKit

public let kNUMBEROFMESSAGES = 40

// MARK: - ===== VK =====

public let groupID = "-55347641"

public let KEY_VK_DIDAUTH = "vkAuth"
public let KEY_VK_USERCANCELAUTH = "vkUserCancelAuth"

public let URL_BASE = "https://api.vk.com/method"
public let URL_WALL_FEED = "/wall.get?"
public let URL_PHOTOS = "/photos.get?"
public let URL_PHOTO_ALBUMS = "/photos.getAlbums?"
public let URL_COMMENTS = "/wall.getComments?"
public let URL_USERS = "/users.get?"

public let URL_LIKES_ADD = "/likes.add?"
public let URL_LIKES_DELETE = "/likes.delete?"
public let URL_ISLIKED = "/likes.isLiked?"

public enum URL_PARAMS: String {
    
    case OWNER_ID = "owner_id="
    case COUNT = "count="
    case OFFSET = "offset="
    case EXTENDED = "extended="
    
    case REV = "rev="
    case ALBUM_ID = "album_id="
    
    case NEED_COVERS = "need_covers="
    
    case LANG = "lang="
    
    case POST_ID = "post_id="
    case NEED_LIKES = "need_likes="
    
    case USER_IDS = "user_ids="
    case USER_FIELDS = "fields="
    
    case ACCESS_TOKEN = "access_token="
    
    case ITEM_TYPE = "type="
    case ITEM_ID = "item_id="
    
}


// MARK: - ===== Type Alias ====

typealias DownloadComplete = ([Any]) -> Void
typealias AuthoizationComplete = (User) -> Void
typealias LikeFeatureCompletion = ([String: Any]) -> Void


// MARK: - ===== UI Settings ====

//let mainShadowColor = UIColor(colorLiteralRed: 120/255, green: 120/255, blue: 120/255, alpha: 1.0)
let mainShadowColor = UIColor(netHex: 0x787878)
var shadowWidth: CGFloat = 1.0
var shadowHeight: CGFloat = 2.0
var shadowOpacity: Float = 0.6
var shadowColor = mainShadowColor

var shadowRadius: CGFloat = 4.0

//let mainThemeColor = UIColor(colorLiteralRed: 226/255, green: 226/255, blue: 226/255, alpha: 1)

let mainThemeColor = UIColor(netHex: 0xe2e2e2)

//let cellSelectionColor = UIColor(netHex: 0x7F7DFF)

let cellSelectionColor = UIColor(white: 1.0, alpha: 0.2)




// MARK: - ==== CAMERA SETTINGS ===
let kMAXDURATION: Double = 20.0



