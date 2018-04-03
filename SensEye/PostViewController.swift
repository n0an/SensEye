//
//  PostViewController.swift
//  SensEye
//
//  Created by Anton Novoselov on 04/01/2017.
//  Copyright © 2017 Anton Novoselov. All rights reserved.
//

import UIKit
import Jelly
import IDMPhotoBrowser

class PostViewController: GeneralFeedViewController {
    
    // MARK: - OUTLETS
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var logoutFromVKButton: UIButton!
    
    // MARK: - PROPERTIES
    public var wallPost: WallPost!
    public var backgroundImage: UIImage?
    
    weak var delegate: PostViewControllerDelegate?
    
    var comments: [Comment] = []
    let commentsInRequest = 10
    
    var loadingData = false
    
    fileprivate var jellyAnimator: JellyAnimator?
    
    var headerView: PostHeaderView!
    fileprivate var headerMaskLayer: CAShapeLayer!
    
    var postDataSource: PostVCDataSource!
    var cellDelegate: WallPostCellDelegate!
    
    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        postDataSource = PostVCDataSource(vc: self)
        cellDelegate = WallPostCellDelegate(vc: self)
        
        self.loadingData = true
        getCommentsFromServer()
        
        tableView.delegate = cellDelegate
        tableView.dataSource = postDataSource
        
        tableView.rowHeight = UITableViewAutomaticDimension
        
        self.tableView.addInfiniteScrolling {
            self.getCommentsFromServer()
        }
        
        headerView = tableView.tableHeaderView as! PostHeaderView
        headerView.delegate = self
        
        headerView.updateUI(withPost: wallPost, andImage: backgroundImage)
        
        tableView.allowsSelection = false
        
        tableView.tableHeaderView = nil
        tableView.addSubview(headerView)
        
        tableView.contentInset = UIEdgeInsets(top: Storyboard.tableHeaderHeight, left: 0, bottom: 0, right: 0)
        tableView.contentOffset = CGPoint(x: 0, y: -Storyboard.tableHeaderHeight)
        
        headerMaskLayer = CAShapeLayer()
        headerMaskLayer.fillColor = UIColor.black.cgColor
        headerView.layer.mask = headerMaskLayer
        
        updateHeaderView()
        
        listenForAuthenticationNotification()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        refreshLogoutButton()
    }
    
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        updateHeaderView()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateHeaderView()
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        delegate?.postViewControllerWillDisappear(withPost: self.wallPost)
    }
    
    
    // MARK: - API METHODS
    func refreshLogoutButton() {
        
        if checkIfCurrentVKUserExists()  {
            self.logoutFromVKButton.isHidden = false
        } else {
            self.logoutFromVKButton.isHidden = true
        }
    }
    
    func refreshMainPost() {
        
        GeneralHelper.sharedHelper.showSpinner(onView: self.view, usingBoundsFromView: self.tableView)
        
        isLiked(forItemType: .post, ownerID: groupID, itemID: self.wallPost.postID) { (resultDict) in
            
            if let resultDict = resultDict {
                
                if let liked = resultDict["liked"] as? Int {
                    self.wallPost.isLikedByCurrentUser = liked == 1 ? true : false
                    let cell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as! FeedCell
                    cell.wallPost = self.wallPost
                    
                } else {
                    self.wallPost.isLikedByCurrentUser = false
                    let cell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as! FeedCell
                    cell.wallPost = self.wallPost
                }
                
            } else {
                self.wallPost.isLikedByCurrentUser = false
                let cell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as! FeedCell
                cell.wallPost = self.wallPost
            }
            
            GeneralHelper.sharedHelper.hideSpinner(onView: self.view)
        }
    }
    
    func refreshComments() {
        
        if self.loadingData == false {
            self.loadingData = true
            
            GeneralHelper.sharedHelper.showSpinner(onView: self.view, usingBoundsFromView: self.tableView)
            
            getFeed(forType: .comment, ownerID: groupID, postID: wallPost.postID, offset: 0, count: max(commentsInRequest, self.comments.count), completed: { (comments) in
                
                if comments.count > 0 {
                    guard let comments = comments as? [Comment] else { return }
                    self.comments.removeAll()
                    self.comments.append(contentsOf: comments)
                    self.wallPost.postComments = String(comments.count)
                    self.tableView.reloadData()
                }
            })
            
            self.loadingData = false
            GeneralHelper.sharedHelper.hideSpinner(onView: self.view)
        }
    }
    
    func getCommentsFromServer() {
        
        GeneralHelper.sharedHelper.showSpinner(onView: self.view, usingBoundsFromView: self.tableView)
        
        getFeed(forType: .comment, ownerID: groupID, postID: wallPost.postID, offset: self.comments.count, count: commentsInRequest) { (comments) in
            
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
    
    // MARK: - HELPER METHODS
    
    func updateHeaderView() {
        let effectiveHeight = Storyboard.tableHeaderHeight - Storyboard.tableHeaderCutAway / 2
        
        var headerRect = CGRect(x: 0, y: -effectiveHeight, width: tableView.bounds.width, height: Storyboard.tableHeaderHeight)
        
        headerView.logoImageView.alpha = 0
        
        if tableView.contentOffset.y < -effectiveHeight {
            headerRect.origin.y = tableView.contentOffset.y
            headerRect.size.height = -tableView.contentOffset.y + Storyboard.tableHeaderCutAway/2
            
            let final: CGFloat = -100
            let alpha =  min((tableView.contentOffset.y + effectiveHeight) / final, 1)
            headerView.logoImageView.alpha = alpha
        }
        
        headerView.frame = headerRect
        
        // cut away
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: headerRect.width, y: 0))
        path.addLine(to: CGPoint(x: headerRect.width, y: headerRect.height))
        path.addLine(to: CGPoint(x: 0, y: headerRect.height - Storyboard.tableHeaderCutAway))
        headerMaskLayer?.path = path.cgPath
    }
    
    // MARK: - NOTIFICATIONS
    func listenForAuthenticationNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(vkAuthorizationCompleted), name: Notification.Name.ANNotificationAuthorizationCompleted, object: nil)
    }
    
    // MARK: - ACTIONS
    @objc func vkAuthorizationCompleted() {
        refreshLogoutButton()
        refreshMainPost()
        refreshComments()
    }
    
    // MARK: - NAVIGATION
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == Storyboard.segueCommentComposer {
            let destinationNVC = segue.destination as! UINavigationController
            let destinationVC = destinationNVC.topViewController as! CommentComposerViewController
            destinationVC.delegate = self
            destinationVC.wallPost = self.wallPost
        }
    }
}


// MARK: - UIScrollViewDelegate
extension PostViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        updateHeaderView()
        
        let offsetY = scrollView.contentOffset.y
        let adjustment: CGFloat = 100
        
        if (-offsetY) > (Storyboard.tableHeaderHeight + adjustment) {
            self.dismiss(animated: true, completion: nil)
        }
        
        if (-offsetY) > (Storyboard.tableHeaderHeight) {
            self.headerView.pullDownToCloseLabel.isHidden = false
        } else {
            self.headerView.pullDownToCloseLabel.isHidden = true
        }
    }
}


// MARK: - === PostHeaderViewDelegate ===
extension PostViewController: PostHeaderViewDelegate {
    
    func closeButtonTapped() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func logoutFromVKButtonTapped() {
        deAuthorize { (success) in
            
        }
    }
}


// MARK: - === CommentComposerViewControllerDelegate ===
extension PostViewController: CommentComposerViewControllerDelegate {
    func commentDidSend(withPost post: WallPost) {
        refreshMainPost()
        refreshComments()
    }
}

