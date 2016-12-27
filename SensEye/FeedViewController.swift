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
    
    // MARK: - OUTLETS
    @IBOutlet weak var tableView: UITableView!
    
    
    // MARK: - PROPERTIES
    enum Storyboard {
        static let cellId = "FeedCell"
        static let rowHeight: CGFloat = 370
        
        static let seguePhotoDisplayer = "showPhoto"
    }
    
    var wallPosts: [WallPost] = []

    // MARK: - viewDidLoad

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
    
    
    // MARK: - HELPER METHODS
    
    
    
    // MARK: - ACTIONS
    
    
    // MARK: - NAVIGATION
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Storyboard.seguePhotoDisplayer {
            
            let destinationNavVC = segue.destination as! UINavigationController
            
            
            let destinationVC = destinationNavVC.topViewController as! PhotoViewController
            
            guard let senderTuple = sender as? (WallPost, Int) else {
                return
            }
            
            let selectedPost = senderTuple.0
            let indexOfPhoto = senderTuple.1
            
            if let photoAttach = selectedPost.postAttachments[0] as? Photo {
                
                destinationVC.currentPhoto = photoAttach
                destinationVC.mediasArray = selectedPost.postAttachments
                destinationVC.currentIndex = indexOfPhoto
                
                
            } else if let albumAttach = selectedPost.postAttachments[0] as? PhotoAlbum {
                destinationVC.currentPhoto = albumAttach.albumThumbPhoto
                destinationVC.mediasArray = [albumAttach.albumThumbPhoto]
                destinationVC.currentIndex = 0
            }
            
        }
    }
    
    @IBAction func unwindToFeedVC(segue: UIStoryboardSegue) {
        
    }
        
    

}




// MARK: - UITableViewDataSource
extension FeedViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return wallPosts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.cellId, for: indexPath) as! FeedCell
        
        let wallPost = self.wallPosts[indexPath.row]
        
        cell.wallPost = wallPost
        cell.delegate = self
        
        // *** ADDING POST IMAGES GALLERY

        let postGallery = PostPhotoGallery(withTableViewWidth: self.tableView.frame.width)
        
        postGallery.insertGallery(forPost: wallPost, toCell: cell)
        
        
        return cell
        
    }
    
    
}


// MARK: - UITableViewDelegate
extension FeedViewController: UITableViewDelegate {
    
    
    
}



// MARK: - FeedCellDelegate

extension FeedViewController: FeedCellDelegate {
    
    func galleryImageViewDidTap(wallPost: WallPost, clickedPhotoIndex: Int) {
        
        performSegue(withIdentifier: Storyboard.seguePhotoDisplayer, sender: (wallPost, clickedPhotoIndex))
        
        
        
    }
}






















