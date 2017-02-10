//
//  Photo.swift
//  SensEye
//
//  Created by Anton Novoselov on 26/12/2016.
//  Copyright © 2016 Anton Novoselov. All rights reserved.
//

import Foundation

// MARK: - PHOTO CONSTANTS
let kPhoto_75 = "photo_75";
let kPhoto_130 = "photo_130";
let kPhoto_604 = "photo_604";
let kPhoto_807 = "photo_807";
let kPhoto_1280 = "photo_1280";
let kPhoto_2560 = "photo_2560";

enum PhotoResolution: Int {
    case res75
    case res130
    case res604
    case res807
    case res1280
    case res2560
}

class Photo {
    
    // MARK: - PROPERTIES
    var photoID: String!
    var width: Int!
    var height: Int!
    
    var photo_75: String?
    var photo_130: String?
    var photo_604: String?
    var photo_807: String?
    var photo_1280: String?
    var photo_2560: String?
    
    var maxRes: String?
    
    var keysResArray: [String]
    var resolutionDictionary: [String: String?]!

    // MARK: - INITIALIZERS
    init(responseObject: [String: Any]) {
        
        if let photoID = responseObject["id"] as? String {
            self.photoID = photoID
        } else if let photoID = responseObject["id"] as? Int {
            self.photoID = String(photoID)
        }
        
        if let width = responseObject["width"] as? Int {
            self.width = width
        }
        
        if let height = responseObject["height"] as? Int {
            self.height = height
        }
        
        if let photo_75 = responseObject[kPhoto_75] as? String {
            self.photo_75 = photo_75
        }
        
        if let photo_130 = responseObject[kPhoto_130] as? String {
            self.photo_130 = photo_130
        }
        
        if let photo_604 = responseObject[kPhoto_604] as? String {
            self.photo_604 = photo_604
        }
        
        if let photo_807 = responseObject[kPhoto_807] as? String {
            self.photo_807 = photo_807
        }
        
        if let photo_1280 = responseObject[kPhoto_1280] as? String {
            self.photo_1280 = photo_1280
        }
        
        if let photo_2560 = responseObject[kPhoto_2560] as? String {
            self.photo_2560 = photo_2560
        }
        
        self.resolutionDictionary = [
            kPhoto_75   :   self.photo_75,
            kPhoto_130  :   self.photo_130,
            kPhoto_604  :   self.photo_604,
            kPhoto_807  :   self.photo_807,
            kPhoto_1280 :   self.photo_1280,
            kPhoto_2560 :   self.photo_2560
        ]
        
        self.keysResArray = [kPhoto_75, kPhoto_130, kPhoto_604, kPhoto_807, kPhoto_1280, kPhoto_2560]
        
        var index = PhotoResolution.res2560.rawValue
        
        while index >= PhotoResolution.res130.rawValue {
            let res = self.keysResArray[index]
           
            if let currentRes = resolutionDictionary[res], currentRes != nil {
                self.maxRes = currentRes
                break
            }
            
            index -= 1
        }
    }
}



extension Photo: Equatable { }

func ==(lhs: Photo, rhs: Photo) -> Bool {
    return lhs.photoID == rhs.photoID
}






