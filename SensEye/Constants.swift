//
//  Constants.swift
//  SensEye
//
//  Created by Anton Novoselov on 26/12/2016.
//  Copyright © 2016 Anton Novoselov. All rights reserved.
//

import UIKit

let URL_BASE = "https://api.vk.com/method"
let URL_WALL_FEED = "/wall.get?"
let URL_PHOTOS = "/photos.get?"
let URL_PHOTO_ALBUMS = "/photos.getAlbums?"

enum URL_PARAMS: String {
    
    case OWNER_ID = "owner_id="
    case COUNT = "count="
    case OFFSET = "offset="
    case EXTENDED = "extended="
    
    case REV = "rev="
    case ALBUM_ID = "album_id="
    
    case NEED_COVERS = "need_covers="
    
    case LANG = "lang="
}



typealias DownloadComplete = ([Any]) -> Void

let groupID = "-55347641"


//let mainShadowColor = UIColor(colorLiteralRed: 120/255, green: 120/255, blue: 120/255, alpha: 1.0)
let mainShadowColor = UIColor(netHex: 0x787878)

//let mainThemeColor = UIColor(colorLiteralRed: 226/255, green: 226/255, blue: 226/255, alpha: 1)

let mainThemeColor = UIColor(netHex: 0xf2f2f2)
