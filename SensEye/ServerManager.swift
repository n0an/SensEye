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
    
    private var vkAccessToken: VKAccessToken?
    
    var currentVKUser: User?
    
    enum FeedItemsType: String {
        case post = "post"
        case comment = "comment"
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
    
    
    // MARK: - VK AUTHORIZATION
    
    func tokenToDictionary(token: VKAccessToken) -> [String: Any] {
        
        let tokenDictionary = [
                    "tokenString"       : token.token,
                    "expirationDate"    : token.expirationDate,
                    "userID"            : token.userID
        ] as [String : Any]
        
        return tokenDictionary
        
    }
    
    func postAuthCompleteNotification() {
        
        let center = NotificationCenter.default
        let notification = Notification(name: Notification.Name(rawValue: "NotificationAuthorizationCompleted"))
        
        center.post(notification)
    }
    
    func renewAuthorization(completed: @escaping AuthoizationComplete) {
        let loginVC = VKLoginViewController { (accessToken) in
            if let token = accessToken {
                
                self.vkAccessToken = token
                
                print("token.expirationDate = \(token.expirationDate)")
                print("NOW = \(Date())")
                
                let tokenDict = self.tokenToDictionary(token: token)
                
                UserDefaults.standard.set(tokenDict, forKey: KEY_VK_TOKEN)
                
                UserDefaults.standard.set(true, forKey: KEY_VK_DIDAUTH)
                
                UserDefaults.standard.synchronize()
                
                self.getUserFor(userID: token.userID, completed: { (user) in
                    self.postAuthCompleteNotification()
                    completed(user)
                    
                })
                
            }
        }
        
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        var top = appDelegate.window?.rootViewController
        
        // Peel Off presented view controllers from rootViewController
        while (top?.presentedViewController != nil) {
            top = top?.presentedViewController
        }
        
        
        let nav = UINavigationController(rootViewController: loginVC)
        
        
        top?.present(nav, animated: true, completion: nil)

    }
    
    func authorize(completed: @escaping AuthoizationComplete) {
        
        if let tokenDict = UserDefaults.standard.object(forKey: KEY_VK_TOKEN) as? [String: Any] {
            
            print("saved tokenDict = \(tokenDict)")
            
            let tokenString = tokenDict["tokenString"] as! String
            let expirationDate = tokenDict["expirationDate"] as! Date
            let userID = tokenDict["userID"] as! String
            
            print("expirationDate.timeIntervalSince(Date()) = \(expirationDate.timeIntervalSince(Date()))")
            
            // Refresh token if it will expire in less than 1 hour
            if expirationDate.timeIntervalSince(Date()) <= 3600 {
                
                self.renewAuthorization(completed: completed)
                
            } else {
                
                let vkAccessToken = VKAccessToken()
                vkAccessToken.token = tokenString
                vkAccessToken.expirationDate = expirationDate
                vkAccessToken.userID = userID
                
                self.vkAccessToken = vkAccessToken
                
                UserDefaults.standard.set(true, forKey: KEY_VK_DIDAUTH)
                
                UserDefaults.standard.synchronize()
                
                self.getUserFor(userID: userID, completed: { (user) in
                    self.postAuthCompleteNotification()

                    completed(user)
                })
            }
            
            
            
        } else {
            
            self.renewAuthorization(completed: completed)
        }
        
        
        
    }
    
    
    // MARK: - PHOTOS FEATURE
    
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
    
    
    // MARK: - POSTS/COMMENTS FEATURE
    
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
        
        if let accessToken = self.vkAccessToken {
            url += "&\(URL_PARAMS.ACCESS_TOKEN.rawValue)\(accessToken.token!)"
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
    
    // MARK: - USER FEATURE
    
    func getUserFor(userID: String, completed: @escaping AuthoizationComplete) {
        
        let url = "\(URL_BASE)\(URL_USERS)" +
                    "\(URL_PARAMS.USER_IDS.rawValue)\(userID)&" +
                    "\(URL_PARAMS.USER_FIELDS.rawValue)photo_50&" +
                    "\(URL_PARAMS.LANG.rawValue)ru"
        
        let finalUrl = url + "&v=5.60"

        self.networkActivityIndicatorVisible = true
        
        Alamofire.request(finalUrl).responseJSON { (responseJson) in
            
            self.networkActivityIndicatorVisible = false
            
            guard let responseRoot = responseJson.result.value as? [String: Any] else {return}
            
            guard let response = responseRoot["response"] as? [Any] else {return}
            
            
            
            if response.count > 0 {
                let userItem = response[0] as! [String: Any]
                
                let user = User(responseObject: userItem)
                
                completed(user)
            }
            
            
            
        }
        
    }
    
    // MARK: - LIKES FEATURE
    
    func isLiked(forItemType itemType: FeedItemsType, ownerID: String, itemID: String, completed: @escaping LikeFeatureCompletion) {
        
        
        var url = "\(URL_BASE)\(URL_ISLIKED)" +
                    "\(URL_PARAMS.ITEM_TYPE.rawValue)\(itemType.rawValue)&" +
                    "\(URL_PARAMS.ITEM_ID.rawValue)\(itemID)&" +
                    "\(URL_PARAMS.OWNER_ID.rawValue)\(ownerID)"
        
        if let accessToken = self.vkAccessToken {
            url += "&\(URL_PARAMS.ACCESS_TOKEN.rawValue)\(accessToken.token!)"
        }
        
        let finalUrl = url + "&v=5.60"
        
        self.networkActivityIndicatorVisible = true

        Alamofire.request(finalUrl).responseJSON { (responseJson) in
            
            self.networkActivityIndicatorVisible = false
            
            guard let responseRoot = responseJson.result.value as? [String: Any] else {return}
            
            guard let response = responseRoot["response"] as? [String:Any] else {return}
            
            completed(response)
            
        }
        
        
    }
    
    func addLike(forItemType itemType: FeedItemsType, ownerID: String, itemID: String, completed: @escaping LikeFeatureCompletion) {
        
        
        var url = "\(URL_BASE)\(URL_LIKES_ADD)" +
                    "\(URL_PARAMS.ITEM_TYPE.rawValue)\(itemType.rawValue)&" +
                    "\(URL_PARAMS.ITEM_ID.rawValue)\(itemID)&" +
                    "\(URL_PARAMS.OWNER_ID.rawValue)\(ownerID)"
        
        if let accessToken = self.vkAccessToken {
            url += "&\(URL_PARAMS.ACCESS_TOKEN.rawValue)\(accessToken.token!)"
        }
        
        let finalUrl = url + "&v=5.60"
        
        self.networkActivityIndicatorVisible = true

        Alamofire.request(finalUrl, method: .post, parameters: [:], encoding: JSONEncoding.default, headers: nil).responseJSON { (responseJson) in
            
            self.networkActivityIndicatorVisible = false
            
            guard let responseRoot = responseJson.result.value as? [String: Any] else {return}
            
            guard let response = responseRoot["response"] as? [String:Any] else {return}
            
            completed(response)
            
            
        }
        
        
    }
    
    
    func deleteLike(forItemType itemType: FeedItemsType, ownerID: String, itemID: String, completed: @escaping LikeFeatureCompletion) {
        
        
        var url = "\(URL_BASE)\(URL_LIKES_DELETE)" +
                    "\(URL_PARAMS.ITEM_TYPE.rawValue)\(itemType.rawValue)&" +
                    "\(URL_PARAMS.ITEM_ID.rawValue)\(itemID)&" +
                    "\(URL_PARAMS.OWNER_ID.rawValue)\(ownerID)"
        
        if let accessToken = self.vkAccessToken {
            url += "&\(URL_PARAMS.ACCESS_TOKEN.rawValue)\(accessToken.token!)"
        }
        
        let finalUrl = url + "&v=5.60"
        
        self.networkActivityIndicatorVisible = true
        
        Alamofire.request(finalUrl, method: .post, parameters: [:], encoding: JSONEncoding.default, headers: nil).responseJSON { (responseJson) in
            
            self.networkActivityIndicatorVisible = false
            
            guard let responseRoot = responseJson.result.value as? [String: Any] else {return}
            
            guard let response = responseRoot["response"] as? [String:Any] else {return}
            
            completed(response)
            
        }
        
        
    }
    
    
    
    // MARK: - HELPER METHODS
    
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
    
 
    
}













