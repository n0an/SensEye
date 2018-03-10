//
//  ServerManager.swift
//  SensEye
//
//  Created by Anton Novoselov on 26/12/2016.
//  Copyright © 2016 Anton Novoselov. All rights reserved.
//

import Foundation
import Alamofire
import SwiftKeychainWrapper
import SwiftyJSON

typealias SuccessHandler = ([Any]) -> Void
typealias FailureHandler = (NSError, Int) -> Void

class ServerManager {
    
    // MARK: - PROPERTIES
    enum FeedItemsType: String {
        case post = "post"
        case comment = "comment"
    }
    
    static let sharedManager = ServerManager()
    
    static let standartParams: [String: Any] =
        [URL_PARAMS.VER.rawValue: "5.60"]
    
    private var vkAccessToken: VKAccessToken?
    
    var currentVKUser: User?
    
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
                
                let tokenDict = self.tokenToDictionary(token: token)
                
                KeychainWrapper.standard.set(tokenDict as NSDictionary, forKey: KEY_VK_TOKEN)
                
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
    
    func deAuthorize(completed: @escaping (Bool) -> Void) {
        
        let removeSuccessful = KeychainWrapper.standard.removeObject(forKey: KEY_VK_TOKEN)
        
        UserDefaults.standard.set(false, forKey: KEY_VK_DIDAUTH)
        UserDefaults.standard.set(false, forKey: KEY_VK_USERCANCELAUTH)

        self.vkAccessToken = nil
        self.currentVKUser = nil
        
        postAuthCompleteNotification()
        
        completed(removeSuccessful)
    }
    
    func authorize(completed: @escaping AuthoizationComplete) {
        
        if let tokenDict = KeychainWrapper.standard.object(forKey: KEY_VK_TOKEN) as? [String: Any] {
            
            let tokenString = tokenDict["tokenString"] as! String
            let expirationDate = tokenDict["expirationDate"] as! Date
            let userID = tokenDict["userID"] as! String
            
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
        
        let url = URL(string: URL_BASE)?.appendingPathComponent(URL_PHOTOS)
        
        var params = ServerManager.standartParams
        
        params[URL_PARAMS.OWNER_ID.rawValue] = ownerID
        params[URL_PARAMS.ALBUM_ID.rawValue] = albumID
        params[URL_PARAMS.REV.rawValue] = 0
        params[URL_PARAMS.EXTENDED.rawValue] = 1

        if let offset = offset {
            
            params[URL_PARAMS.OFFSET.rawValue] = offset
        }
        
        if let count = count {
            params[URL_PARAMS.COUNT.rawValue] = count
        }
        
        self.networkActivityIndicatorVisible = true
        
        Alamofire.request(url!, method: .get, parameters: params, encoding: URLEncoding(), headers: nil).responseJSON { (responseJson) in
            
            self.networkActivityIndicatorVisible = false
            
            switch responseJson.result {
            case .success(let jsonValue):
              
                guard let responseRoot = jsonValue as? [String: Any] else {return}
                guard let response = responseRoot["response"] as? [String: Any] else {return}
                guard let photoItemsArray = response["items"] as? [Any] else {return}
                
                var photosArray: [Photo] = []
                
                for item in photoItemsArray {
                    let photoItem = item as! [String: Any]
                    let photo = Photo(responseObject: photoItem)
                    photosArray.append(photo)
                }
                
                completed(photosArray)
                
            case .failure(let error):
                print("error: \(error.localizedDescription)")
                
            }
        }
    }
    
    func getPhotoAlbums(forGroupID groupID: String, completed: @escaping DownloadComplete) {
        
        let url = URL(string: URL_BASE)?.appendingPathComponent(URL_PHOTO_ALBUMS)
        
        var params = ServerManager.standartParams
        
        params[URL_PARAMS.OWNER_ID.rawValue] = groupID
        params[URL_PARAMS.NEED_COVERS.rawValue] = 1
        
        self.networkActivityIndicatorVisible = true
        
        Alamofire.request(url!, method: .get, parameters: params, encoding: URLEncoding(), headers: nil).responseJSON { (responseJson) in
            
            self.networkActivityIndicatorVisible = false
            
            switch responseJson.result {
            case .success(let jsonValue):
                
                guard let responseRoot = jsonValue as? [String: Any] else {return}
                guard let response = responseRoot["response"] as? [String: Any] else {return}
                guard let albumItemsArray = response["items"] as? [Any] else {return}
                
                var albumsArray: [PhotoAlbum] = []
                
                for item in albumItemsArray {
                    let albumItem = item as! [String: Any]
                    let photoAlbum = PhotoAlbum(responseObject: albumItem)
                    albumsArray.append(photoAlbum)
                }
                
                completed(albumsArray)
                
            case .failure(let error):
                print("error: \(error.localizedDescription)")
                
            }
        }
    }
    
    // MARK: - POSTS/COMMENTS FEATURE
    func getFeed(forType feedType: FeedItemsType, ownerID: String, postID: String? = nil, offset: Int, count: Int, completed: @escaping DownloadComplete) {
        
        let methodPathComponent = feedType == .comment ? URL_COMMENTS : URL_WALL_FEED
        
        let url = URL(string: URL_BASE)?.appendingPathComponent(methodPathComponent)
        
        var params = ServerManager.standartParams
        
        params[URL_PARAMS.OWNER_ID.rawValue] = ownerID
        params[URL_PARAMS.COUNT.rawValue] = count
        params[URL_PARAMS.OFFSET.rawValue] = offset
        params[URL_PARAMS.LANG.rawValue] = "ru"
        params[URL_PARAMS.EXTENDED.rawValue] = 1

        if feedType == .comment {
            params[URL_PARAMS.POST_ID.rawValue] = postID!
            params[URL_PARAMS.NEED_LIKES.rawValue] = 1
        }
        
        if let accessToken = self.vkAccessToken {
            params[URL_PARAMS.ACCESS_TOKEN.rawValue] = accessToken.token!
        } else {
            params[URL_PARAMS.ACCESS_TOKEN.rawValue] = GeneralHelper.sharedHelper.serviceVKToken
        }
        
        self.networkActivityIndicatorVisible = true
        
        Alamofire.request(url!, method: .get, parameters: params, encoding: URLEncoding(), headers: nil).responseJSON { (responseJson) in
            
            self.networkActivityIndicatorVisible = false
            
            switch responseJson.result {
            case .success(let jsonValue):
                
                guard let responseRoot = jsonValue as? [String: Any] else {return}
                guard let response = responseRoot["response"] as? [String: Any] else {return}
                guard let itemsArray = response["items"] as? [Any] else {return}
                guard let profilesArray = response["profiles"] as? [Any] else {return}
                guard let groupsArray = response["groups"] as? [Any] else {return}
                
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
                    
                    var cleanedParsedObjects = [WallPost]()
                    
                    for post in parsedObjects {
                        if post.postText != "" || post.postAttachments != nil {
                            cleanedParsedObjects.append(post)
                        }
                    }
                    
                    completed(cleanedParsedObjects)
                    
                } else {
                    let parsedObjects: [Comment] = self.parseFeedObjects(forArray: itemsArray, authorsArray: authorsArray, group: group)
                    
                    completed(parsedObjects)
                }
                
            case .failure(let error):
                print("error: \(error.localizedDescription)")
                
            }
        }
    }
    
    func createComment(ownerID: String, postID: String, message: String, completed: @escaping (Bool) -> Void) {
        
        let url = URL(string: URL_BASE)?.appendingPathComponent(URL_CREATE_COMMENT)
        
        var params = ServerManager.standartParams
        
        params[URL_PARAMS.OWNER_ID.rawValue] = ownerID
        params[URL_PARAMS.POST_ID.rawValue] = postID
        params[URL_PARAMS.MESSAGE.rawValue] = message
        
        if let accessToken = self.vkAccessToken {
            params[URL_PARAMS.ACCESS_TOKEN.rawValue] = accessToken.token!
        } else {
            params[URL_PARAMS.ACCESS_TOKEN.rawValue] = GeneralHelper.sharedHelper.serviceVKToken
        }
        
        self.networkActivityIndicatorVisible = true
        
        Alamofire.request(url!, method: .post, parameters: params, encoding: URLEncoding(), headers: nil).responseJSON { (responseJson) in
            
            self.networkActivityIndicatorVisible = false
            
            switch responseJson.result {
            case .success(let jsonValue):
                
                guard let responseRoot = jsonValue as? [String: Any] else {return}
                guard let response = responseRoot["response"] as? [String: Any] else {return}
                guard (response["comment_id"] as? Int) != nil else { return }
                
                completed(true)
                
            case .failure(let error):
                print("error: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - USER FEATURE
    func getUserFor(userID: String, completed: @escaping AuthoizationComplete) {
        
        let url = URL(string: URL_BASE)?.appendingPathComponent(URL_USERS)
        
        var params = ServerManager.standartParams
        
        params[URL_PARAMS.USER_IDS.rawValue] = userID
        params[URL_PARAMS.USER_FIELDS.rawValue] = "photo_50"
        params[URL_PARAMS.LANG.rawValue] = "ru"
        
        self.networkActivityIndicatorVisible = true
        
        Alamofire.request(url!, method: .post, parameters: params, encoding: URLEncoding(), headers: nil).responseJSON { (responseJson) in
            
            self.networkActivityIndicatorVisible = false
            
            switch responseJson.result {
            case .success(let jsonValue):
                
                guard let responseRoot = jsonValue as? [String: Any] else {return}
                guard let response = responseRoot["response"] as? [Any] else {return}
                
                if response.count > 0 {
                    let userItem = response[0] as! [String: Any]
                    let user = User(responseObject: userItem)
                    completed(user)
                }
                
            case .failure(let error):
                print("error: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - LIKES FEATURE
    func isLiked(forItemType itemType: FeedItemsType, ownerID: String, itemID: String, completed: @escaping ([String: Any]?) -> Void) {
        
        let url = URL(string: URL_BASE)?.appendingPathComponent(URL_ISLIKED)
        
        var params = ServerManager.standartParams
        
        params[URL_PARAMS.ITEM_TYPE.rawValue] = itemType.rawValue
        params[URL_PARAMS.ITEM_ID.rawValue]   = itemID
        params[URL_PARAMS.OWNER_ID.rawValue]  = ownerID
        
        if let accessToken = self.vkAccessToken {
            params[URL_PARAMS.ACCESS_TOKEN.rawValue] = accessToken.token!
        }
        
        self.networkActivityIndicatorVisible = true
        
        Alamofire.request(url!, method: .post, parameters: params, encoding: URLEncoding(), headers: nil).responseJSON { (responseJson) in
            
            self.networkActivityIndicatorVisible = false
            
            switch responseJson.result {
            case .success(let jsonValue):
                
                guard let responseRoot = jsonValue as? [String: Any] else {return}
                guard let response = responseRoot["response"] as? [String:Any] else {
                    completed(nil)
                    return
                }
                
                completed(response)
                
            case .failure(let error):
                print("error: \(error.localizedDescription)")
            }
        }
    }
    
    func modifyLike(addLike: Bool, forItemType itemType: FeedItemsType, ownerID: String, itemID: String, completed: @escaping LikeFeatureCompletion) {
        
        let pathComponent = addLike ? URL_LIKES_ADD : URL_LIKES_DELETE
        
        let url = URL(string: URL_BASE)?.appendingPathComponent(pathComponent)
        
        var params = ServerManager.standartParams
        
        params[URL_PARAMS.ITEM_TYPE.rawValue] = itemType.rawValue
        params[URL_PARAMS.ITEM_ID.rawValue]   = itemID
        params[URL_PARAMS.OWNER_ID.rawValue]  = ownerID
        
        if let accessToken = self.vkAccessToken {
            params[URL_PARAMS.ACCESS_TOKEN.rawValue] = accessToken.token!
        }
        
        self.networkActivityIndicatorVisible = true
        
        Alamofire.request(url!, method: .post, parameters: params, encoding: URLEncoding(), headers: nil).responseJSON { (responseJson) in
            
            self.networkActivityIndicatorVisible = false
            
            switch responseJson.result {
            case .success(let jsonValue):
                
                guard let responseRoot = jsonValue as? [String: Any] else {
                    completed(false, nil)
                    return
                }
                
                guard let response = responseRoot["response"] as? [String:Any] else {
                    completed(false, nil)
                    return
                }
                
                completed(true, response)
                
            case .failure(let error):
                print("error: \(error.localizedDescription)")
            }
        }
    }
    
    func addLike(forItemType itemType: FeedItemsType, ownerID: String, itemID: String, completed: @escaping LikeFeatureCompletion) {
        
        modifyLike(addLike: true, forItemType: itemType, ownerID: ownerID, itemID: itemID, completed: completed)
    }
    
    func deleteLike(forItemType itemType: FeedItemsType, ownerID: String, itemID: String, completed: @escaping LikeFeatureCompletion) {
        
        modifyLike(addLike: false, forItemType: itemType, ownerID: ownerID, itemID: itemID, completed: completed)
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




