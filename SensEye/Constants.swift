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

enum URL_PARAMS: String {
    
    case OWNER_ID = "owner_id="
    case COUNT = "count="
    case OFFSET = "offset="
    case EXTENDED = "extended="
    
    
}



typealias DownloadComplete = ([WallPost]) -> Void




