//
//  FeedDataSource.swift
//  SensEye
//
//  Created by Anton Novoselov on 22/03/2018.
//  Copyright © 2018 Anton Novoselov. All rights reserved.
//

import UIKit
import Alamofire

class FeedDataSource: NSObject, UITableViewDataSource, FeedProtocol {
    
    var wallPosts: [WallPost] = []
    var wallPostsOffset = 0
    
    weak var vc: FeedViewController?
    
    init(vc: FeedViewController) {
        self.vc = vc
    }
    
    // MARK: - API METHODS
    func getPostsFromServer() {
        
        GeneralHelper.sharedHelper.showSpinner(onView: (self.vc?.view)!, usingBoundsFromView: (self.vc?.tableView)!)
        
        getFeed(forType: .post, ownerID: groupID, offset: self.wallPostsOffset, count: postsInRequest) { (posts) in
            
            if posts.count > 0 {
                guard let posts = posts as? [WallPost] else { return }
                
                self.wallPostsOffset += postsInRequest
                
                if self.wallPosts.count == 0 {
                    self.wallPosts = posts
                    self.vc?.tableView.reloadData()
                    
                } else {
                    self.wallPosts.append(contentsOf: posts)
                    var newPaths = [IndexPath]()
                    var index = self.wallPosts.count - posts.count
                    
                    while index < self.wallPosts.count {
                        let newIndPath = IndexPath(row: index, section: 0)
                        newPaths.append(newIndPath)
                        
                        index += 1
                    }
                    
                    self.vc?.tableView.beginUpdates()
                    self.vc?.tableView.insertRows(at: newPaths, with: .fade)
                    self.vc?.tableView.endUpdates()
                }
            }
            self.vc?.loadingData = false
            GeneralHelper.sharedHelper.hideSpinner(onView: (self.vc?.view)!)
            self.vc?.tableView.infiniteScrollingView.stopAnimating()
        }
    }
    
    func refreshWall() {
        if self.vc?.loadingData == false {
            self.vc?.loadingData = true
            
            GeneralHelper.sharedHelper.showSpinner(onView: (self.vc?.view)!, usingBoundsFromView: (self.vc?.tableView)!)
            
            let postsCountToFetch = max(postsInRequest, wallPostsOffset)
            
            getFeed(forType: .post, ownerID: groupID, offset: 0, count: postsCountToFetch) { (posts) in
                
                if posts.count > 0 {
                    self.wallPostsOffset = postsCountToFetch
                    guard let posts = posts as? [WallPost] else { return }
                    self.wallPosts.removeAll()
                    self.wallPosts.append(contentsOf: posts)
                    self.vc?.tableView.reloadData()
                }
                
                self.vc?.loadingData = false
                GeneralHelper.sharedHelper.hideSpinner(onView: (self.vc?.view)!)
                self.vc?.refreshControl.endRefreshing()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return wallPosts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.cellIdFeed, for: indexPath) as! FeedCell
        
        let wallPost = self.wallPosts[indexPath.row]
        
        cell.wallPost = wallPost
        cell.delegate = vc?.cellDelegate
        
        return cell
    }
}
