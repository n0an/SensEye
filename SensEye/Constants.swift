//
//  Constants.swift
//  SensEye
//
//  Created by Anton Novoselov on 26/12/2016.
//  Copyright © 2016 Anton Novoselov. All rights reserved.
//

import Foundation

let URL_BASE = "https://api.vk.com/method"
let URL_WALL_FEED = "/wall.get?"
let URL_PHOTOS = "/photos.get?"

enum URL_PARAMS: String {
    
    case OWNER_ID = "owner_id="
    case COUNT = "count="
    case OFFSET = "offset="
    case EXTENDED = "extended="
    
    case REV = "rev="
    case ALBUM_ID = "album_id="
    
}



typealias DownloadComplete = ([Any]) -> Void

let groupID = "-55347641"

