//
//  PostVCDataSource.swift
//  SensEye
//
//  Created by Anton Novoselov on 02/04/2018.
//  Copyright © 2018 Anton Novoselov. All rights reserved.
//

import UIKit

class PostVCDataSource: NSObject, UITableViewDataSource {
    
    var comments: [Comment] = []
    
    weak var vc: PostViewController?
    
    init(vc: PostViewController) {
        self.vc = vc
    }
    
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
            let postCell = tableView.dequeueReusableCell(withIdentifier: Storyboard.cellIdFeed, for: indexPath) as! FeedCell
            
            postCell.wallPost = vc?.wallPost
            postCell.delegate = vc?.cellDelegate
            
            return postCell
            
        } else {
            let commentCell = tableView.dequeueReusableCell(withIdentifier: Storyboard.cellIdComment, for: indexPath) as! CommentCell
            
            let comment = self.comments[indexPath.row]
            
            commentCell.comment = comment
            commentCell.delegate = vc?.cellDelegate
            
            return commentCell
        }
    }
    
}
