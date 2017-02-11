//
//  FRStorageManager.swift
//  SensEye
//
//  Created by Anton Novoselov on 18/01/2017.
//  Copyright © 2017 Anton Novoselov. All rights reserved.
//

import Foundation
import Firebase

// MARK: - CONSTANTS
let STORAGE_ROOT        = FIRStorage.storage().reference()
let IMAGES_REF          = "images"
let IMAGES_AVATAR_REF   = "avatars"
let VIDEOS_REF          = "videos"

class FRStorageManager {
    
    // MARK: - PROPERTIES
    private static let _sharedManager = FRStorageManager()
    
    static var sharedManager: FRStorageManager {
        return _sharedManager
    }
    
    // MARK: - PUBLIC PROPERTIES
    var REF_STORAGE_IMAGES = STORAGE_ROOT.child(IMAGES_REF)
    var REF_STORAGE_VIDEOS = STORAGE_ROOT.child(VIDEOS_REF)
    var REF_STORAGE_AVATARS = STORAGE_ROOT.child(IMAGES_AVATAR_REF)
}




