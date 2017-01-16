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
    
    private var refreshControl: UIRefreshControl!
    
    var observer: AnyObject!
    
    // MARK: - viewDidLoad

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.tintColor = UIColor(red: 20/255, green: 160/255, blue: 160/255, alpha: 1)
        
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
        
//        self.tableView.addPullToRefresh { 
//            print("PullToRefresh GO")
//            self.refreshWall()
//        }
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(actionRefreshTableView), for: .valueChanged)
        self.tableView.refreshControl = refreshControl
        self.refreshControl = refreshControl
        
        
        listenForBackgroundNotification()
        
        listenForAuthenticationNotification()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let currentVKUser = ServerManager.sharedManager.currentVKUser
        
        let userDidAuth = UserDefaults.standard.bool(forKey: KEY_VK_DIDAUTH)
        let userCancelAuth = UserDefaults.standard.bool(forKey: KEY_VK_USERCANCELAUTH)
        
        
        if currentVKUser == nil && userDidAuth == true && userCancelAuth != true {
            
            self.toAuthorize()
            
        }

    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        // To redraw Photos with new size after transition to portrait or landscape
        tableView.reloadData()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(observer)
        NotificationCenter.default.removeObserver(self)
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
//                self.tableView.pullToRefreshView.stopAnimating()
                self.refreshControl.endRefreshing()
            }
        }
    }
    
    // MARK: - HELPER ACTIONS
    
    fileprivate func createVC(withID identifier: String) -> UIViewController? {
        return self.storyboard?.instantiateViewController(withIdentifier: identifier)
    }
    
    
    // MARK: - NOTIFICATIONS
    
    // HIDING ALERTS, ACTIONS SHEETS, PICKERS WHEN APP GOES TO BACKGROUND
    
    func listenForBackgroundNotification() {
        
        self.observer = NotificationCenter.default.addObserver(forName: NSNotification.Name.UIApplicationDidEnterBackground, object: nil, queue: OperationQueue.main) { [weak self] _ in
            
            if let strongSelf = self {
                if strongSelf.presentedViewController != nil {
                    strongSelf.dismiss(animated: false, completion: nil)
                }
                
            }
            
        }
        
    }

    func listenForAuthenticationNotification() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(vkAuthorizationCompleted), name: Notification.Name(rawValue: "NotificationAuthorizationCompleted"), object: nil)
        
    }
    
    
    // MARK: - ACTIONS
    
    func vkAuthorizationCompleted() {
        self.refreshWall()
    }
    
    func actionRefreshTableView() {
        self.refreshWall()
    }
    
    
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
            
            destinationVC.delegate = self
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




// MARK: - ===FeedCellDelegate===

extension FeedViewController: FeedCellDelegate {
    
    func toAuthorize() {
        
        ServerManager.sharedManager.authorize { (user) in
            
            ServerManager.sharedManager.currentVKUser = user
            
            
        }
        
    }
    
    
    func provideAuthorization() {
        
        UserDefaults.standard.set(false, forKey: KEY_VK_USERCANCELAUTH)
        UserDefaults.standard.synchronize()

        
        GeneralHelper.sharedHelper.showVKAuthorizeActionSheetOnViewController(viewController: self) { (selected) in
            
            if selected == true {
                self.toAuthorize()
            }
            
        }
        
    }
    

    func performJellyTransition(withPhotos photosArray: [Photo], indexOfPhoto: Int) {
        if let photoDisplayerNavVC = self.createVC(withID: Storyboard.viewControllerIdPhotoDisplayer) as? UINavigationController {
            
            let photoDisplayerVC = photoDisplayerNavVC.topViewController as! PhotoViewController
            
            photoDisplayerVC.currentPhoto = photosArray[indexOfPhoto]
            photoDisplayerVC.mediasArray = photosArray
            photoDisplayerVC.currentIndex = indexOfPhoto
            

            
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


// MARK: - === PostViewControllerDelegate ===

extension FeedViewController: PostViewControllerDelegate {
    
    func postViewControllerWillDisappear(withPost post: WallPost) {
        
        if let index = self.wallPosts.index(of: post) {
            
            let indexPath = IndexPath(row: index, section: 0)
            let cell = tableView.cellForRow(at: indexPath) as! FeedCell
            
            cell.updateUI()
            
        }
    }
    
  
    
}





