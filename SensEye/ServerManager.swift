//
//  ServerManager.swift
//  SensEye
//
//  Created by Anton Novoselov on 26/12/2016.
//  Copyright © 2016 Anton Novoselov. All rights reserved.
//

import Foundation
import Alamofire

typealias SuccessHandler = ([Any]) -> Void
typealias FailureHandler = (NSError, Int) -> Void

class ServerManager {
    
    static let sharedManager = ServerManager()
    
    // MARK: - GROUP WALL
    
    func getGroupWall(forGroupID groupID: String, offset: Int, count: Int, completed: @escaping DownloadComplete) {
        
        let url = "\(URL_BASE)\(URL_WALL_FEED)" +
                    "\(URL_PARAMS.OWNER_ID.rawValue)\(groupID)&" +
                    "\(URL_PARAMS.COUNT.rawValue)\(count)&" +
                    "\(URL_PARAMS.OFFSET.rawValue)\(offset)&" +
                    "\(URL_PARAMS.EXTENDED.rawValue)1"
        
        
        let finalUrl = url + "&v=5.60"
        
//        print(finalUrl)
        
        Alamofire.request(finalUrl).responseJSON { (responseJson) in
            
//            print(responseJson)
            
            guard let responseRoot = responseJson.result.value as? [String: Any] else {return}
            
            guard let response = responseRoot["response"] as? [String: Any] else {return}
            
            guard let wallFeed = response["items"] as? [Any] else {
                return
            }
            
            guard let profilesArray = response["profiles"] as? [Any] else {
                return
            }
            
            guard let groupsArray = response["groups"] as? [Any] else {
                return
            }
            
            
            // Parsing Group object
            
            let group = Group(responseObject: groupsArray[0] as! [String : Any])
            
            // Parsing Profiles
            
            var authorsArray = [User]()
            
            for item in profilesArray {
                
                let profileItem = item as! [String: Any]
                
                let profile = User(responseObject: profileItem)
                
                authorsArray.append(profile)
                
            }
            
            
            
            var postsArray = [WallPost]()
            
            for item in wallFeed {
                
                let postItem = item as! [String: Any]
                
                let post = WallPost(responseObject: postItem)
                
                postsArray.append(post)

                // Iterating through array of authors - looking for author for this post
                
                for author in authorsArray {
                    
                    if post.postAuthorID.hasPrefix("-") {
                        post.postGroupAuthor = group
                        break
                    }
                    
                    if author.userID == post.postAuthorID {
                        post.postAuthor = author
                        break
                    }
                }
                
                
                
            }
            
            completed(postsArray)
   
            
            
        }
        
        
        
    }
    
    
    
    
    
//    func getGroupWall(forGroupID groupID: String, offset: Int, count: Int, onSuccess: SuccessHandler, onFailure: FailureHandler) {
//        
//        let params = [
//            
//            groupID:    "owner_id",
//            offset:     "offset",
//            count:      "count",
//     
//        ] as [AnyHashable : String]
//        
//        let groupWallURL = URL(string: "wall.get", relativeTo: baseURL)
//        
//        
//        
//        
//    }
    
    
    
    
}













