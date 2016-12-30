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
    let postsInRequest = 10

    var loadingData = false
    
    let slideRightTransitionAnimator = SlideRightTransitionAnimator()
    let popTransitionAnimator = PopTransitionAnimator()
    let slideRightThenPopTransitionAnimator = SlideRightThenPopTransitionAnimator()
    
    let acSlideDownTransition = ACSlideDownTransitionAnimator()
    let acSlideRightTransition = ACSlideRightTransitionAnimator()
    let acPopTransition = ACPopTransitionAnimator()
    let acRotateTransition = ACRotateTransitionAnimator()
    
    
    // MARK: - viewDidLoad

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.loadingData = true
        getPostsFromServer()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.estimatedRowHeight = Storyboard.rowHeight
        tableView.rowHeight = UITableViewAutomaticDimension
        
        self.tableView.addInfiniteScrolling { 
            print("InfiniteScrolling GO")
            self.getPostsFromServer()
        }
        
        self.tableView.addPullToRefresh { 
            print("PullToRefresh GO")
            self.refreshWall()
        }
    }

    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        // To redraw Photos with new size after transition to portrait or landscape
        tableView.reloadData()
    }

    
    
    // MARK: - API METHODS
    
    func getPostsFromServer() {
        ServerManager.sharedManager.getGroupWall(forGroupID: groupID, offset: self.wallPosts.count, count: postsInRequest) { (posts) in
            
            if posts.count > 0 {
                
                guard let posts = posts as? [WallPost] else { return }
                
                if self.wallPosts.count == 0 {
                    
                    self.wallPosts = posts
                    self.tableView.reloadData()
                    
                } else {
                    
                    self.wallPosts.append(contentsOf: posts)
                    
                    var newPaths = [IndexPath]()
                    
                    var index = self.wallPosts.count - posts.count
                    
                    while index < self.wallPosts.count {
                        
                        let newIndPath = IndexPath(row: index, section: 0)
                        newPaths.append(newIndPath)
                        
                        index += 1
                    }
                    
                    self.tableView.beginUpdates()
                    self.tableView.insertRows(at: newPaths, with: .fade)
                    self.tableView.endUpdates()
                }
                
                
            }
            
            self.loadingData = false
            self.tableView.infiniteScrollingView.stopAnimating()
            
        }
    }
    
    func refreshWall() {
        
        if self.loadingData == false {
            
            self.loadingData = true
            
            ServerManager.sharedManager.getGroupWall(forGroupID: groupID, offset: 0, count: max(postsInRequest, self.wallPosts.count), completed: { (posts) in
                
                if posts.count > 0 {
                    
                    guard let posts = posts as? [WallPost] else { return }
                    
                    self.wallPosts.removeAll()
                    
                    self.wallPosts.append(contentsOf: posts)
                    
                    self.tableView.reloadData()
                    
                }
                
                self.loadingData = false
                self.tableView.pullToRefreshView.stopAnimating()
                
            })
            
            
        }
        
        
    }
    
    
    // MARK: - ACTIONS
    
    
    // MARK: - NAVIGATION
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Storyboard.seguePhotoDisplayer {
            
            let destinationNavVC = segue.destination as! UINavigationController
            
//            destinationNavVC.transitioningDelegate = popTransitionAnimator
            
//            destinationNavVC.transitioningDelegate = slideRightThenPopTransitionAnimator
            
//            destinationNavVC.transitioningDelegate = slideRightTransitionAnimator
            
//            destinationNavVC.transitioningDelegate = acRotateTransition
//            destinationNavVC.transitioningDelegate = acSlideDownTransition
//            destinationNavVC.transitioningDelegate = acSlideRightTransition

            destinationNavVC.transitioningDelegate = acPopTransition
            
            
            
            
            let destinationVC = destinationNavVC.topViewController as! PhotoViewController
            
            
//
            
            
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
                
                // Calculating index of clicked photo in album
                
                let indexOfClickedPhotoInAlbum = photos.index(of: albumAttach.albumThumbPhoto!)
                
                self.performSegue(withIdentifier: Storyboard.seguePhotoDisplayer, sender: (photos, indexOfClickedPhotoInAlbum ?? clickedPhotoIndex))
                
            })
            
            
        }
        
        
    }
}























