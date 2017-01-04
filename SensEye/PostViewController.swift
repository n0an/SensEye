//
//  PostViewController.swift
//  SensEye
//
//  Created by Anton Novoselov on 04/01/2017.
//  Copyright © 2017 Anton Novoselov. All rights reserved.
//

import UIKit

import Jelly

class PostViewController: UIViewController {
    
    // MARK: - OUTLETS
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - PROPERTIES
    
    public var wallPost: WallPost!
    
    enum Storyboard {
        static let cellIdPost = "FeedCell"
        static let cellIdComment = "CommentCell"
        
        static let rowHeightPostCell: CGFloat = 370
        static let rowHeightCommentCell: CGFloat = 100

        static let seguePhotoDisplayer = "showPhoto"
        
        static let viewControllerIdPhotoDisplayer = "PhotoNavViewController"
    }
    
    enum TableViewSectionType: Int {
        case post
        case comment
    }
    
    var comments: [Comment] = []
    let commentsInRequest = 10
    
    var loadingData = false
    
    fileprivate var jellyAnimator: JellyAnimator?
    
    // MARK: - viewDidLoad

    override func viewDidLoad() {
        super.viewDidLoad()

        self.loadingData = true
        getCommentsFromServer()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.rowHeight = UITableViewAutomaticDimension
        
        self.tableView.addInfiniteScrolling {
            print("InfiniteScrolling GO")
            self.getCommentsFromServer()
        }
        
        self.tableView.addPullToRefresh {
            print("PullToRefresh GO")
//            self.refreshPost()
        }

    }

    // MARK: - API METHODS
    func getCommentsFromServer() {
        
        GeneralHelper.sharedHelper.showSpinner(onView: self.view, usingBoundsFromView: self.tableView)
        
        ServerManager.sharedManager.getFeed(forType: .comment, ownerID: groupID, postID: wallPost.postID, offset: self.comments.count, count: commentsInRequest) { (comments) in
            
            if comments.count > 0 {
                
                guard let comments = comments as? [Comment] else { return }
                
                self.comments.append(contentsOf: comments)
                
                var newPaths = [IndexPath]()
                
                var index = self.comments.count - comments.count
                
                while index < self.comments.count {
                    
                    let newIndPath = IndexPath(row: index, section: TableViewSectionType.comment.rawValue)
                    newPaths.append(newIndPath)
                    
                    index += 1
                }
                
                self.tableView.beginUpdates()
                self.tableView.insertRows(at: newPaths, with: .fade)
                self.tableView.endUpdates()
                
                
            }
            
            self.loadingData = false
            GeneralHelper.sharedHelper.hideSpinner(onView: self.view)
            self.tableView.infiniteScrollingView.stopAnimating()
            
            
        }
        
        
    }
    
    
    
    

}


// MARK: - UITableViewDataSource
extension PostViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == TableViewSectionType.comment.rawValue {
            return comments.count
        } else {
            return 1
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == TableViewSectionType.post.rawValue {
            
            let postCell = tableView.dequeueReusableCell(withIdentifier: Storyboard.cellIdPost, for: indexPath) as! FeedCell
            
            postCell.wallPost = self.wallPost
            
            postCell.commentButton.isEnabled = false
            
            return postCell
            
        } else {
            
            let commentCell = tableView.dequeueReusableCell(withIdentifier: Storyboard.cellIdComment, for: indexPath) as! CommentCell
            
            let comment = self.comments[indexPath.row]
            
            commentCell.comment = comment
            //        cell.delegate = self
            
            return commentCell
        }
        
        
        
        
    }
    
}

// MARK: - UITableViewDelegate

extension PostViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if indexPath.section == TableViewSectionType.post.rawValue {
            return Storyboard.rowHeightPostCell
        } else {
            return Storyboard.rowHeightCommentCell
        }
        
    }
    
    
    
}
















































