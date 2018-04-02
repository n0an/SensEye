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
import IDMPhotoBrowser
import RevealingSplashView

enum Storyboard {
    static let feedCellId               = "FeedCell"
    static let feedRowHeight: CGFloat   = 370.0
    static let seguePostVC              = "showPost"
    static let segueCommentComposer     = "ShowCommentComposer"
}

class FeedViewController: UIViewController, FeedProtocol, AuthorizationProtocol {
    
    // MARK: - OUTLETS
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - PROPERTIES
    
    let revealingSplashView = RevealingSplashView(iconImage: UIImage(named: "dark_crop_1000")!, iconInitialSize: CGSize.init(width: 249, height: 133), backgroundColor: UIColor.white)
    
    let postsInRequest = 10

    var loadingData = false
    
//    fileprivate var jellyAnimator: JellyAnimator?
    
    private var refreshControl: UIRefreshControl!
    
    var observer: AnyObject!
    
    var customRefreshView: UIView!
    var logoImageView: UIImageView!
    var isLogoAnimating = false
    
    var splashAnimated = false
    
    var feedDataSource: FeedDataSource!
    var cellDelegate: CellDelegate!
    
    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        feedDataSource = FeedDataSource(vc: self)
        cellDelegate = CellDelegate(vc: self)
        
        tableView.delegate = feedDataSource
        tableView.dataSource = feedDataSource
        
        tableView.estimatedRowHeight = Storyboard.feedRowHeight
        tableView.rowHeight = UITableViewAutomaticDimension
        
        self.tableView.addInfiniteScrolling { 
            self.getPostsFromServer()
        }
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(actionRefreshTableView), for: .valueChanged)
        
        refreshControl.backgroundColor = UIColor.clear
        refreshControl.tintColor = UIColor.clear
        
        if #available(iOS 10.0, *) {
            self.tableView.refreshControl = refreshControl
        } else {
            // Fallback on earlier versions
            self.tableView.addSubview(refreshControl)
        }
        
        self.view.addSubview(revealingSplashView)
        revealingSplashView.animationType = .heartBeat
        revealingSplashView.startAnimation()
        
        self.refreshControl = refreshControl
        
        loadCustomRefreshContents()
        
        listenForBackgroundNotification()
        listenForAuthenticationNotification()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let currentVKUser = ServerManager.sharedManager.currentVKUser
        
        let userDidAuth = UserDefaults.standard.bool(forKey: KEY_VK_DIDAUTH)
        let userCancelAuth = UserDefaults.standard.bool(forKey: KEY_VK_USERCANCELAUTH)
        
        if currentVKUser == nil {
            
            if userDidAuth && !userCancelAuth {
                self.toAuthorize()
                
            } else {
                if feedDataSource.wallPosts.count == 0 {
                    self.loadingData = true
                    getPostsFromServer()
                }
            }
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        // To redraw Photos with new size after transition to portrait or landscape
        tableView.reloadData()
    }
    
    // MARK: - deinit
    deinit {
        if observer != nil {
            NotificationCenter.default.removeObserver(observer)
        }
        NotificationCenter.default.removeObserver(self)
    }

    
    // MARK: - API METHODS
    func getPostsFromServer() {
        
        GeneralHelper.sharedHelper.showSpinner(onView: self.view, usingBoundsFromView: self.tableView)
        
        
        ServerManager.sharedManager.getFeed(forType: .post, ownerID: groupID, offset: self.feedDataSource.wallPosts.count, count: postsInRequest) { (posts) in
            
            if posts.count > 0 {
                guard let posts = posts as? [WallPost] else { return }
                
                if self.feedDataSource.wallPosts.count == 0 {
                    self.feedDataSource.wallPosts = posts
                    self.tableView.reloadData()
                    
                } else {
                    self.feedDataSource.wallPosts.append(contentsOf: posts)
                    var newPaths = [IndexPath]()
                    var index = self.feedDataSource.wallPosts.count - posts.count
                    
                    while index < self.feedDataSource.wallPosts.count {
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
            
            self.revealingSplashView.heartAttack = true
        }
    }
    
    func refreshWall() {
        if self.loadingData == false {
            self.loadingData = true
            
            GeneralHelper.sharedHelper.showSpinner(onView: self.view, usingBoundsFromView: self.tableView)
            
            ServerManager.sharedManager.getFeed(forType: .post, ownerID: groupID, offset: 0, count: max(postsInRequest, feedDataSource.wallPosts.count)) { (posts) in
                
                if posts.count > 0 {
                    guard let posts = posts as? [WallPost] else { return }
                    self.feedDataSource.wallPosts.removeAll()
                    self.feedDataSource.wallPosts.append(contentsOf: posts)
                    self.tableView.reloadData()
                }
                
                self.loadingData = false
                GeneralHelper.sharedHelper.hideSpinner(onView: self.view)
                self.refreshControl.endRefreshing()
            }
        }
    }
    
    // MARK: - HELPER METHODS
    func toAuthorize() {
        authorize { (user) in
            ServerManager.sharedManager.currentVKUser = user
        }
    }
    
    func loadCustomRefreshContents() {
        let refreshContents = Bundle.main.loadNibNamed("RefreshContents", owner: self, options: nil)
        self.customRefreshView = refreshContents?[0] as! UIView
        self.customRefreshView.frame = self.refreshControl.bounds
        
        self.logoImageView = self.customRefreshView.subviews[0] as! UIImageView
        
        self.refreshControl.addSubview(self.customRefreshView)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        if refreshControl.isRefreshing {
            if !isLogoAnimating {
                animateRefresh()
            }
        }
    }
    
    // MARK: - ANIMATIONS
    func animateRefresh() {
        
        isLogoAnimating = true
        
        GeneralHelper.sharedHelper.showDGSpinnter(withType: .ballBeat, onView: self.customRefreshView, withPosition: .right, andColor: UIColor.brown)
        
        UIView.animate(withDuration: 0.6, delay: 0.0, options: .curveLinear, animations: {
            let transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
            
            self.logoImageView.transform = transform
            self.logoImageView.alpha = 0.0
            
        }) { (finished) in
            UIView.animate(withDuration: 0.25, delay: 0.0, options: .curveLinear, animations: {
                self.logoImageView.transform = .identity
                self.logoImageView.alpha = 1.0
                
            }, completion: { (finished) in
                if self.refreshControl.isRefreshing {
                    self.animateRefresh()
                    
                } else {
                    self.isLogoAnimating = false
                    self.logoImageView.transform = .identity
                    self.logoImageView.alpha = 0.0

                    GeneralHelper.sharedHelper.hideDGSpinner(onView: self.customRefreshView)
                }
            })
        }
    }
    
    
    // MARK: - NOTIFICATIONS
    // ** HIDING ALERTS, ACTIONS SHEETS, PICKERS WHEN APP GOES TO BACKGROUND
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
        NotificationCenter.default.addObserver(self, selector: #selector(vkAuthorizationCompleted), name: Notification.Name.ANNotificationAuthorizationCompleted, object: nil)
    }
    
    // MARK: - ACTIONS
    @objc func vkAuthorizationCompleted() {
        self.refreshWall()
    }
    
    @objc func actionRefreshTableView() {
        self.refreshWall()
    }
    
    // MARK: - NAVIGATION
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == Storyboard.seguePostVC {
            let destinationVC = segue.destination as! PostViewController
            
            guard let postCell = sender as? FeedCell else {
                return
            }
            
            destinationVC.delegate = self
            destinationVC.wallPost = postCell.wallPost
            destinationVC.backgroundImage = postCell.galleryImageViews[0].image
            
        } else if segue.identifier == Storyboard.segueCommentComposer {
            let destinationNVC = segue.destination as! UINavigationController
            
            let destinationVC = destinationNVC.topViewController as! CommentComposerViewController
            
            destinationVC.delegate = self
            
            destinationVC.wallPost = sender as! WallPost
        }
    }
}


// MARK: - === PostViewControllerDelegate ===
extension FeedViewController: PostViewControllerDelegate {
    
    func postViewControllerWillDisappear(withPost post: WallPost) {
        if let index = self.feedDataSource.wallPosts.index(of: post) {
            
            let indexPath = IndexPath(row: index, section: 0)
            let cell = tableView.cellForRow(at: indexPath) as! FeedCell
            
            cell.updateUI()
        }
    }
}


// MARK: - === CommentComposerViewControllerDelegate ===
extension FeedViewController: CommentComposerViewControllerDelegate {
    
    func commentDidSend(withPost post: WallPost) {
        
        if let index = self.feedDataSource.wallPosts.index(of: post) {
            let indexPath = IndexPath(row: index, section: 0)
            let commentedPost = self.feedDataSource.wallPosts[index]
            let initialCommentsCount = Int(commentedPost.postComments)
            
            commentedPost.postComments = String(initialCommentsCount! + 1)
            
            tableView.reloadRows(at: [indexPath], with: .automatic)
        }
    }
    
}



