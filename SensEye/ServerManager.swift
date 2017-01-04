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
    
    enum FeedItemsType {
        case post
        case comment
    }
    
    var networkActivityIndicatorVisible: Bool = false {
        didSet {
            if networkActivityIndicatorVisible == true {
                
                UIApplication.shared.isNetworkActivityIndicatorVisible = true
            } else {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
            
        }
    }
    
    // MARK: - PHOTOS
    func getPhotos(forAlbumID albumID: String, ownerID: String, offset: Int? = nil, count: Int? = nil, completed: @escaping DownloadComplete) {
        
        var url = "\(URL_BASE)\(URL_PHOTOS)" +
            "\(URL_PARAMS.OWNER_ID.rawValue)\(ownerID)&" +
            "\(URL_PARAMS.ALBUM_ID.rawValue)\(albumID)&" +
            "\(URL_PARAMS.REV.rawValue)0&" +
            "\(URL_PARAMS.EXTENDED.rawValue)1"
        
        
        if let offset = offset {
            url += "&\(URL_PARAMS.OFFSET)\(offset)"
        }
        
        if let count = count {
            url += "&\(URL_PARAMS.COUNT)\(count)"
        }
        
        let finalUrl = url + "&v=5.60"
        
        self.networkActivityIndicatorVisible = true
        
        Alamofire.request(finalUrl).responseJSON { (responseJson) in
            
            self.networkActivityIndicatorVisible = false
            
            guard let responseRoot = responseJson.result.value as? [String: Any] else {return}
            
            guard let response = responseRoot["response"] as? [String: Any] else {return}
            
            guard let photoItemsArray = response["items"] as? [Any] else {
                return
            }
            
            var photosArray: [Photo] = []
            
            for item in photoItemsArray {
                
                let photoItem = item as! [String: Any]
                
                let photo = Photo(responseObject: photoItem)
                
                photosArray.append(photo)
            }
            
            completed(photosArray)
            
        }
        
    }
    
    
    
    func getPhotoAlbums(forGroupID groupID: String, completed: @escaping DownloadComplete) {
        
        let url = "\(URL_BASE)\(URL_PHOTO_ALBUMS)" +
            "\(URL_PARAMS.OWNER_ID.rawValue)\(groupID)&" +
            "\(URL_PARAMS.NEED_COVERS.rawValue)1"
        
        let finalUrl = url + "&v=5.60"
        
        self.networkActivityIndicatorVisible = true
        
        Alamofire.request(finalUrl).responseJSON { (responseJson) in
            
            self.networkActivityIndicatorVisible = false
            
            guard let responseRoot = responseJson.result.value as? [String: Any] else {return}
            
            guard let response = responseRoot["response"] as? [String: Any] else {return}
            
            guard let albumItemsArray = response["items"] as? [Any] else {
                return
            }
            
            var albumsArray: [PhotoAlbum] = []
            
            for item in albumItemsArray {
                let albumItem = item as! [String: Any]
                
                let photoAlbum = PhotoAlbum(responseObject: albumItem)
                
                albumsArray.append(photoAlbum)
            }
            
            completed(albumsArray)
            
        }
        
    }
    
    // MARK: - COMMENTS
    
    func getFeed(forType feedType: FeedItemsType, ownerID: String, postID: String? = nil, offset: Int, count: Int, completed: @escaping DownloadComplete) {
        
        var url = ""
        
        if feedType == .comment {
            url = "\(URL_BASE)\(URL_COMMENTS)"
        } else {
            url = "\(URL_BASE)\(URL_WALL_FEED)"
        }
        
        url += "\(URL_PARAMS.OWNER_ID.rawValue)\(ownerID)&" +
                "\(URL_PARAMS.COUNT.rawValue)\(count)&" +
                "\(URL_PARAMS.OFFSET.rawValue)\(offset)&" +
                "\(URL_PARAMS.LANG.rawValue)ru&" +
                "\(URL_PARAMS.EXTENDED.rawValue)1"
        
        
        
        if feedType == .comment {
            url += "&\(URL_PARAMS.POST_ID.rawValue)\(postID!)&" +
                    "\(URL_PARAMS.NEED_LIKES.rawValue)1"
        }
        
        let finalUrl = url + "&v=5.60"
        
        self.networkActivityIndicatorVisible = true
        
        Alamofire.request(finalUrl).responseJSON { (responseJson) in
            
            self.networkActivityIndicatorVisible = false
            
            guard let responseRoot = responseJson.result.value as? [String: Any] else {return}
            
            guard let response = responseRoot["response"] as? [String: Any] else {return}
            
            guard let itemsArray = response["items"] as? [Any] else {
                return
            }
            
            guard let profilesArray = response["profiles"] as? [Any] else {
                return
            }
            
            guard let groupsArray = response["groups"] as? [Any] else {
                return
            }
            
            
            // Parsing Group object
            
            var group: Group?
            
            if groupsArray.count > 0 {
                group = Group(responseObject: groupsArray[0] as! [String : Any])
            }
            
//            let group = Group(responseObject: groupsArray[0] as! [String : Any])
            
            // Parsing Profiles
            
            var authorsArray = [User]()
            
            for item in profilesArray {
                
                let profileItem = item as! [String: Any]
                
                let profile = User(responseObject: profileItem)
                
                authorsArray.append(profile)
                
            }
            
            // Parsing posts or comments objects
            
            if feedType == .post {
                
                let parsedObjects: [WallPost] = self.parseFeedObjects(forArray: itemsArray, authorsArray: authorsArray, group: group)
                
                completed(parsedObjects)
                
            } else {
                
                let parsedObjects: [Comment] = self.parseFeedObjects(forArray: itemsArray, authorsArray: authorsArray, group: group)
                
                completed(parsedObjects)
            }
            
            
            
            
        }
        
        
        
    }
    
    
    func parseFeedObjects<T: ServerObject>(forArray array: [Any], authorsArray: [User], group: Group?) -> [T] {
        
        var feedObjectsArray = [T]()
        
        for item in array {
            
            let postItem = item as! [String: Any]
            
            var post = T(responseObject: postItem)
            
            feedObjectsArray.append(post)
            
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
    
        return feedObjectsArray
    }
    
    
//    func getComments(forPostID postID: String, ownerID: String, offset: Int? = nil, count: Int? = nil, completed: @escaping DownloadComplete) {
//        
//        let url = "\(URL_BASE)\(URL_COMMENTS)" +
//                    "\(URL_PARAMS.OWNER_ID.rawValue)\(groupID)&" +
//                    "\(URL_PARAMS.POST_ID.rawValue)\(postID)&" +
//                    "\(URL_PARAMS.NEED_LIKES.rawValue)1&" +
//                    "\(URL_PARAMS.COUNT.rawValue)\(count)&" +
//                    "\(URL_PARAMS.OFFSET.rawValue)\(offset)&" +
//                    "\(URL_PARAMS.LANG.rawValue)ru&" +
//                    "\(URL_PARAMS.EXTENDED.rawValue)1"
//        
//        
//        let finalUrl = url + "&v=5.60"
//        
//        self.networkActivityIndicatorVisible = true
//        
//        Alamofire.request(finalUrl).responseJSON { (responseJson) in
//            
//            self.networkActivityIndicatorVisible = false
//            
//            guard let responseRoot = responseJson.result.value as? [String: Any] else {return}
//            
//            guard let response = responseRoot["response"] as? [String: Any] else {return}
//
//            guard let commentsArray = response["items"] as? [Any] else {
//                return
//            }
//            
//            guard let profilesArray = response["profiles"] as? [Any] else {
//                return
//            }
//            
//            guard let groupsArray = response["groups"] as? [Any] else {
//                return
//            }
//            
//            
//            
//        }
//        
//        
//    }
    
    
    
    
    // MARK: - GROUP WALL
    
    func getGroupWall(forGroupID groupID: String, offset: Int, count: Int, completed: @escaping DownloadComplete) {
        
        let url = "\(URL_BASE)\(URL_WALL_FEED)" +
                    "\(URL_PARAMS.OWNER_ID.rawValue)\(groupID)&" +
                    "\(URL_PARAMS.COUNT.rawValue)\(count)&" +
                    "\(URL_PARAMS.OFFSET.rawValue)\(offset)&" +
                    "\(URL_PARAMS.LANG.rawValue)ru&" +
                    "\(URL_PARAMS.EXTENDED.rawValue)1"
        
        
        let finalUrl = url + "&v=5.60"
        
        self.networkActivityIndicatorVisible = true
    
        Alamofire.request(finalUrl).responseJSON { (responseJson) in
            
            self.networkActivityIndicatorVisible = false
            
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
    
    
    
    
    
    
 
    
    
}













