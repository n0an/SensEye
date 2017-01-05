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

import Jelly

class FeedViewController: UIViewController {
    
    // MARK: - OUTLETS
    @IBOutlet weak var tableView: UITableView!
    
    
    // MARK: - PROPERTIES
    enum Storyboard {
        static let cellId = "FeedCell"
        static let rowHeight: CGFloat = 370
        
        static let seguePhotoDisplayer = "showPhoto"
        static let seguePostVC = "showPost"

        static let viewControllerIdPhotoDisplayer = "PhotoNavViewController"
    }
    
    var wallPosts: [WallPost] = []
    let postsInRequest = 10

    var loadingData = false
    
    fileprivate var jellyAnimator: JellyAnimator?
    

    
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
        super.viewWillTransition(to: size, with: coordinator)
        // To redraw Photos with new size after transition to portrait or landscape
        tableView.reloadData()
    }

    
    
    // MARK: - API METHODS
    
    func getPostsFromServer() {
        
        GeneralHelper.sharedHelper.showSpinner(onView: self.view, usingBoundsFromView: self.tableView)
        
        
        ServerManager.sharedManager.getFeed(forType: .post, ownerID: groupID, offset: self.wallPosts.count, count: postsInRequest) { (posts) in
            
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
            GeneralHelper.sharedHelper.hideSpinner(onView: self.view)
            self.tableView.infiniteScrollingView.stopAnimating()

            
        }
        
    
    }
    
    func refreshWall() {
        
        if self.loadingData == false {
            
            self.loadingData = true
            
            GeneralHelper.sharedHelper.showSpinner(onView: self.view, usingBoundsFromView: self.tableView)
            
            
            ServerManager.sharedManager.getFeed(forType: .post, ownerID: groupID, offset: 0, count: max(postsInRequest, self.wallPosts.count)) { (posts) in

                if posts.count > 0 {
                    
                    guard let posts = posts as? [WallPost] else { return }
                    
                    self.wallPosts.removeAll()
                    
                    self.wallPosts.append(contentsOf: posts)
                    
                    self.tableView.reloadData()
                    
                }
                
                self.loadingData = false
                GeneralHelper.sharedHelper.hideSpinner(onView: self.view)
                self.tableView.pullToRefreshView.stopAnimating()

            }
            
        }
        
    }
    
    // MARK: - HELPER ACTIONS
    
    fileprivate func createVC(withID identifier: String) -> UIViewController? {
        return self.storyboard?.instantiateViewController(withIdentifier: identifier)
    }
    
    
    // MARK: - ACTIONS
    
    
    // MARK: - NAVIGATION
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Storyboard.seguePhotoDisplayer {
            
            let destinationNavVC = segue.destination as! UINavigationController

            destinationNavVC.transitioningDelegate = TransitionHelper.sharedHelper.acPopTransition
     
            let destinationVC = destinationNavVC.topViewController as! PhotoViewController

            guard let senderTuple = sender as? ([Photo], Int) else {
                return
            }
            
            let photosArray = senderTuple.0
            let indexOfPhoto = senderTuple.1
            
            
            destinationVC.currentPhoto = photosArray[indexOfPhoto]
            destinationVC.mediasArray = photosArray
            destinationVC.currentIndex = indexOfPhoto
            
            
            
        } else if segue.identifier == Storyboard.seguePostVC {
            
            let destinationVC = segue.destination as! PostViewController
            
            guard let postCell = sender as? FeedCell else {
                return
            }
            
            destinationVC.wallPost = postCell.wallPost
            destinationVC.backgroundImage = postCell.galleryImageViews[0].image
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
        
        return cell
        
    }
    
    
}


// MARK: - UITableViewDelegate
extension FeedViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
//        let selectedPost = self.wallPosts[indexPath.row]
        
        let cell = tableView.cellForRow(at: indexPath) as! FeedCell
        
        performSegue(withIdentifier: Storyboard.seguePostVC, sender: cell)
    }
    
}




// MARK: - FeedCellDelegate

extension FeedViewController: FeedCellDelegate {
    
    func performJellyTransition(withPhotos photosArray: [Photo], indexOfPhoto: Int) {
        if let photoDisplayerNavVC = self.createVC(withID: Storyboard.viewControllerIdPhotoDisplayer) as? UINavigationController {
            
            let photoDisplayerVC = photoDisplayerNavVC.topViewController as! PhotoViewController
            
            photoDisplayerVC.currentPhoto = photosArray[indexOfPhoto]
            photoDisplayerVC.mediasArray = photosArray
            photoDisplayerVC.currentIndex = indexOfPhoto
            
//            let customCornerSlideInPresentation = JellySlideInPresentation(cornerRadius: 0,
//                                                                           backgroundStyle: .blur(effectStyle: .light),
//                                                                           jellyness: .jellier,
//                                                                           duration: .normal,
//                                                                           directionShow: .left,
//                                                                           directionDismiss: .right,
//                                                                           widthForViewController: .fullscreen,
//                                                                           heightForViewController: .fullscreen)
//            
//            let testPresentation2 = JellyShiftInPresentation(dismissCurve: .easeIn, presentationCurve: .easeOut, cornerRadius: 0, backgroundStyle: .blur(effectStyle: .light), jellyness: .jelly, duration: .medium, direction: .left, size: .fullscreen)
            
            
            
            let customBlurFadeInPresentation2 = JellyFadeInPresentation(dismissCurve: .easeInEaseOut,
                                                                        presentationCurve: .easeInEaseOut,
                                                                        cornerRadius: 0,
                                                                        backgroundStyle: .blur(effectStyle: .light),
                                                                        duration: .normal,
                                                                        widthForViewController: .fullscreen,
                                                                        heightForViewController: .fullscreen)

            
            self.jellyAnimator = JellyAnimator(presentation: customBlurFadeInPresentation2)
            
            self.jellyAnimator?.prepare(viewController: photoDisplayerNavVC)
            
            self.present(photoDisplayerNavVC, animated: true, completion: nil)
        }
    }
    
    
    
    
    func galleryImageViewDidTap(wallPost: WallPost, clickedPhotoIndex: Int) {
        
        if let photosArray = wallPost.postAttachments as? [Photo] {
            
            
            // ** UNCOMMENT IF USE SEGUE WITH CUSTOM TRANSITIONING ANIMATOR
//            performSegue(withIdentifier: Storyboard.seguePhotoDisplayer, sender: (wallPost.postAttachments as! [Photo], clickedPhotoIndex))
//            
            
            // ** COMMENT IF NOT USE JELLY TRANSITION
            
            performJellyTransition(withPhotos: photosArray, indexOfPhoto: clickedPhotoIndex)

            
        } else if let albumAttach = wallPost.postAttachments[0] as? PhotoAlbum {
            
            ServerManager.sharedManager.getPhotos(forAlbumID: albumAttach.albumID, ownerID: albumAttach.ownerID, completed: { (result) in
                
                let photos = result as! [Photo]
                
                // Calculating index of clicked photo in album
                
                let indexOfClickedPhotoInAlbum = photos.index(of: albumAttach.albumThumbPhoto!)
                
                // ** UNCOMMENT IF USE SEGUE WITH CUSTOM TRANSITIONING ANIMATOR
//                self.performSegue(withIdentifier: Storyboard.seguePhotoDisplayer, sender: (photos, indexOfClickedPhotoInAlbum ?? clickedPhotoIndex))
                
                self.performJellyTransition(withPhotos: photos, indexOfPhoto: indexOfClickedPhotoInAlbum ?? clickedPhotoIndex)

                
                
            })
            
            
        }
        
        
    }
}























