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
import SVPullToRefresh

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
    let postsInRequest = 20


    // MARK: - viewDidLoad

    override func viewDidLoad() {
        super.viewDidLoad()
        
        getPostsFromServer()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.estimatedRowHeight = Storyboard.rowHeight
        tableView.rowHeight = UITableViewAutomaticDimension
        
        self.tableView.addInfiniteScrolling { 
            print("GOT")
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        tableView.triggerInfiniteScrolling()
    }
    
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        // To redraw Photos with new size after transition to portrait or landscape
        tableView.reloadData()
    }

    
    
    // MARK: - API METHODS
    
    func getPostsFromServer() {
        ServerManager.sharedManager.getGroupWall(forGroupID: groupID, offset: 0, count: 10) { (posts) in
            
            self.wallPosts = posts as! [WallPost]
            self.tableView.reloadData()
        }
    }
    
    
    // MARK: - ACTIONS
    
    
    // MARK: - NAVIGATION
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Storyboard.seguePhotoDisplayer {
            
            let destinationNavVC = segue.destination as! UINavigationController
            
            let destinationVC = destinationNavVC.topViewController as! PhotoViewController
            
            guard let senderTuple = sender as? ([Photo], Int) else {
                return
            }
            
            let photosArray = senderTuple.0
            let indexOfPhoto = senderTuple.1
            
            
            destinationVC.currentPhoto = photosArray[indexOfPhoto]
            destinationVC.mediasArray = photosArray
            destinationVC.currentIndex = indexOfPhoto
            
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
        
        if wallPost.postAttachments[0] is Photo {
            
            performSegue(withIdentifier: Storyboard.seguePhotoDisplayer, sender: (wallPost.postAttachments as! [Photo], clickedPhotoIndex))

            
        } else if let albumAttach = wallPost.postAttachments[0] as? PhotoAlbum {
            
            ServerManager.sharedManager.getPhotos(forAlbumID: albumAttach.albumID, ownerID: albumAttach.ownerID, completed: { (result) in
                
                let photos = result as! [Photo]
                
                self.performSegue(withIdentifier: Storyboard.seguePhotoDisplayer, sender: (photos, clickedPhotoIndex))
                
            })
            
            
        }
        
        
    }
}























