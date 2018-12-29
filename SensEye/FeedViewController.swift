//
//  FeedViewController.swift
//  SensEye
//
//  Created by Anton Novoselov on 26/12/2016.
//  Copyright © 2016 Anton Novoselov. All rights reserved.
//

import UIKit
//import AlamofireImage
import SVPullToRefresh

class FeedViewController: GeneralFeedViewController {
    
    // MARK: - OUTLETS
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - PROPERTIES
    var loadingData = false
    var refreshControl: UIRefreshControl!
    var observer: AnyObject!
    var customRefreshView: UIView!
    var logoImageView: LogoImageView!
    var isLogoAnimating = false
    var splashAnimated = false
    var feedDataSource: FeedDataSource!
    var cellDelegate: WallPostCellDelegate!
    
    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
        listenForBackgroundNotification()
        listenForAuthenticationNotification()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let userDidAuth = UserDefaults.standard.bool(forKey: KEY_VK_DIDAUTH)
        let userCancelAuth = UserDefaults.standard.bool(forKey: KEY_VK_USERCANCELAUTH)
        
        if !checkIfCurrentVKUserExists() {
            if userDidAuth && !userCancelAuth {
                self.toAuthorize()
            } else {
                if feedDataSource.wallPosts.count == 0 {
                    self.loadingData = true
                    feedDataSource.getPostsFromServer()
                }
            }
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        // To redraw Photos with new size after transition to portrait or landscape
        if tableView != nil {
            
            tableView.reloadData()
        }
    }
    
    // MARK: - deinit
    deinit {
        if observer != nil {
            NotificationCenter.default.removeObserver(observer)
        }
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - NOTIFICATIONS
    func configureTableView() {
        feedDataSource = FeedDataSource(vc: self)
        cellDelegate = WallPostCellDelegate(vc: self)
        
        tableView.delegate = cellDelegate
        tableView.dataSource = feedDataSource
        
        tableView.estimatedRowHeight = Storyboard.rowHeightFeed
        tableView.rowHeight = UITableViewAutomaticDimension
        
        self.tableView.addInfiniteScrolling {
            self.feedDataSource.getPostsFromServer()
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
        
        self.refreshControl = refreshControl
        loadCustomRefreshContents()
    }
    
    func loadCustomRefreshContents() {
        let refreshContents = Bundle.main.loadNibNamed("RefreshContents", owner: self, options: nil)
        self.customRefreshView = refreshContents?[0] as? UIView
        self.customRefreshView.frame = self.refreshControl.bounds
        self.logoImageView = self.customRefreshView.subviews[0] as? LogoImageView
        self.refreshControl.addSubview(self.customRefreshView)
    }
    
    // MARK: - ANIMATIONS
    func animateRefresh() {
        isLogoAnimating = true
        GeneralHelper.sharedHelper.showDGSpinnter(withType: .ballBeat, onView: self.customRefreshView, withPosition: .right, andColor: UIColor.brown)
        
        self.logoImageView.animateLogo(withVC: self)
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
        self.feedDataSource.refreshWall()
    }
    
    @objc func actionRefreshTableView() {
        self.feedDataSource.refreshWall()
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
