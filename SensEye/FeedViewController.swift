//
//  FeedViewController.swift
//  SensEye
//
//  Created by Anton Novoselov on 26/12/2016.
//  Copyright © 2016 Anton Novoselov. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage


class FeedViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    enum Storyboard {
        static let cellId = "FeedCell"
        static let rowHeight: CGFloat = 370
    }
    
    var wallPosts: [WallPost] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        ServerManager.sharedManager.getGroupWall(forGroupID: "-55347641", offset: 0, count: 10) { (posts) in
            
            print(posts)
            
            self.wallPosts = posts
            
            self.tableView.reloadData()
            
        }
        
        tableView.delegate = self
        tableView.dataSource = self
        
        
        tableView.estimatedRowHeight = Storyboard.rowHeight
        tableView.rowHeight = UITableViewAutomaticDimension

    }

}


extension FeedViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return wallPosts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.cellId, for: indexPath) as! FeedCell
        
        let wallPost = self.wallPosts[indexPath.row]
        
        cell.postTextLabel.text = wallPost.postText
        
        cell.commentButton.setTitle(wallPost.postComments, for: [])
        cell.likeButton.setTitle(wallPost.postLikes, for: [])
        
        
        if let postAuthor = wallPost.postAuthor {
            cell.usernameLabel.text = "\(postAuthor.firstName!) \(postAuthor.lastName!)"
            
        } else if let groupPostAuthor = wallPost.postGroupAuthor {
            cell.usernameLabel.text = "\(groupPostAuthor.groupName!)"

            let imageURL = URL(string: groupPostAuthor.imageURL)
            
            cell.profileImageVIew.af_setImage(withURL: imageURL!)
            
        }
        
        let postGallery = PostPhotoGallery(withTableViewWidth: self.tableView.frame.width)
        
        postGallery.insertGallery(forPost: wallPost, toCell: cell)
        
        
        cell.timestampLabel.text = "\(wallPost.postDate!)"
       
        
        return cell
        
    }
    
    
}

extension FeedViewController: UITableViewDelegate {
    
    
    
}














