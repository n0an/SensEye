//
//  FRImage.swift
//  SensEye
//
//  Created by Anton Novoselov on 18/01/2017.
//  Copyright © 2017 Anton Novoselov. All rights reserved.
//

import Foundation
import Firebase

class FRImage {
    
    // MARK: - PROPERTIES
    var image: UIImage
    var ref: StorageReference!
    
    // MARK: - INITIALIZERS
    init(image: UIImage) {
        self.image = image
    }
    
    // MARK: - UPLOAD METHODS
    func saveAvatarImageToFirebaseStorage(_ userUID: String, completion: @escaping (StorageMetadata?, Error?) -> Void) {
        let resizedImage = self.image.resized(forHeight: 480)
        let imageData = UIImageJPEGRepresentation(resizedImage, 0.5)
        
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpeg"
        
        ref = FRStorageManager.sharedManager.REF_STORAGE_AVATARS.child(userUID)
        
        ref.putData(imageData!, metadata: metaData) { (meta, error) in
            completion(meta, error)
        }
    }
}

extension FRImage {
    // MARK: - DOWNLOAD METHODS
    class func downloadAvatarImageFromFirebaseStorage(_ userUID: String, completion: @escaping (UIImage?, Error?) -> Void) {
        
        let ref = FRStorageManager.sharedManager.REF_STORAGE_AVATARS.child(userUID)
        
        ref.getData(maxSize: 1 * 1024 * 1024) { (imageData, error) in
            if let imageData = imageData {
                let image = UIImage(data: imageData)
                completion(image, nil)
            } else {
                completion(nil, error)
            }
        }
        
    }
}
