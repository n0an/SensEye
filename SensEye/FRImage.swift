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
    var ref: FIRStorageReference!
    
    // MARK: - INITIALIZERS
    init(image: UIImage) {
        self.image = image
    }
    
    func saveAvatarImageToFirebaseStorage(_ userUID: String, completion: @escaping (FIRStorageMetadata?, Error?) -> Void) {
        
        let imageUid = NSUUID().uuidString
        
        let resizedImage = self.image.resized()
    
        let imageData = UIImageJPEGRepresentation(resizedImage, 0.5)
        
        ref = FRStorageManager.sharedManager.REF_STORAGE_AVATARS.child(userUID)
        
        ref.put(imageData!, metadata: nil) { (meta, error) in
            
            completion(meta, error)
            
        }
        
        
        
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
}
