//
//  LandscapeViewController.swift
//  SensEye
//
//  Created by Anton Novoselov on 02/01/2017.
//  Copyright © 2017 Anton Novoselov. All rights reserved.
//

import UIKit
import AlamofireImage

class LandscapeViewController: UIViewController {
    
    // MARK: - OUTLETS
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var pageControl: UIPageControl!
    
    // MARK: - PROPERTIES
    struct ScrollViewParameters {
        var columnsPerPage: Int
        var rowsPerPage: Int
        
        var itemWidth: CGFloat
        var itemHeight: CGFloat
        
        var titleLabelFont = UIFont.systemFont(ofSize: 14.0)
        
        var scrollViewWidth: CGFloat
        var scrollViewHeight: CGFloat
        
        var imageViewWidth: CGFloat
        var imageViewHeight: CGFloat
        
        var firstRowMarginY: CGFloat
        var lastRowMarginY: CGFloat
    }
    
    var scrollViewParams = ScrollViewParameters(columnsPerPage: 3,
                                                rowsPerPage: 1,
                                                itemWidth: 222,
                                                itemHeight: 375,
                                                titleLabelFont: UIFont.systemFont(ofSize: 14.0),
                                                scrollViewWidth: 0,
                                                scrollViewHeight: 0,
                                                imageViewWidth: 206,
                                                imageViewHeight: 300,
                                                firstRowMarginY: 0,
                                                lastRowMarginY: 0)
    
    fileprivate enum Storyboard {
        static let seguePhotoDisplayer              = "showPhoto"
        static let viewControllerIdPhotoDisplayer   = "PhotoNavViewController"
    }
    
    public var albums: [PhotoAlbum] = []
    
    var isPad = false
    
    var isPhonePlus: Bool {
        let rect = UIScreen.main.bounds
        if (rect.width == 736 && rect.height == 414) || (rect.width == 414 && rect.height == 736)  {
            return true
        } else {
            return false
        }
    }
    
    var isPortrait: Bool {
        let rect = UIScreen.main.bounds
        if rect.width / rect.height < 1  {
            return true
        } else {
            return false
        }
    }
    
    weak var splitViewDetail: PhotoViewController?
    
    
    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = NSLocalizedString("Albums", comment: "Gallery Albums")
        
        if self.traitCollection.verticalSizeClass == .regular && self.traitCollection.horizontalSizeClass == .regular {
            self.isPad = true
            self.pageControl.isHidden = true
        }
        
        getAlbumsFromServer()
        
        // TURN OFF AUTO LAYOUT FOR THIS VC
        view.removeConstraints(view.constraints)
        view.translatesAutoresizingMaskIntoConstraints = true
        
        pageControl.removeConstraints(pageControl.constraints)
        pageControl.translatesAutoresizingMaskIntoConstraints = true
        
        scrollView.removeConstraints(scrollView.constraints)
        scrollView.translatesAutoresizingMaskIntoConstraints = true
        
        pageControl.numberOfPages = 0
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        updateUI()
    }
    
    func updateUI() {
        for view in scrollView.subviews {
            view.removeFromSuperview()
        }
        
        scrollView.frame = view.bounds
        
        if isPhonePlus {
            if isPortrait {
                pageControl.isHidden = false
            } else {
                pageControl.isHidden = true
            }
        }
        
        var diff: CGFloat = 0
        
        if !isPad {
            if isPortrait {
                diff = (tabBarController?.tabBar.bounds.height)!
            } else {
                diff = 0
            }
        }
        
        pageControl.frame = CGRect(x: 0,
                                   y: view.frame.size.height - pageControl.frame.size.height - diff,
                                   width: view.frame.size.width,
                                   height: pageControl.frame.size.height)
        
        scrollView.contentOffset = .zero
        
        self.tileAlbums(albums: albums)
    }
    
    
    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        
        super.willTransition(to: newCollection, with: coordinator)
        
        if UIDevice.current.userInterfaceIdiom != .pad {
            let tabBarController = UIApplication.shared.keyWindow?.rootViewController as! UITabBarController
            
            switch newCollection.verticalSizeClass {
            case .compact:
                // Hide TabBar
                if tabBarController.selectedIndex == TabBarIndex.gallery.rawValue {
                    self.tabBarController?.tabBar.layer.zPosition = -1
                    self.tabBarController?.tabBar.isUserInteractionEnabled = false
                }
                
            case .regular, .unspecified:
                // Show TabBar
                if tabBarController.selectedIndex == TabBarIndex.gallery.rawValue {
                    self.tabBarController?.tabBar.layer.zPosition = 0
                    self.tabBarController?.tabBar.isUserInteractionEnabled = true
                }
            }
        }
    }
    
    
    // MARK: - API METHODS
    func getAlbumsFromServer() {
        
        getPhotoAlbums(forGroupID: groupID) { (result) in
            guard let albums = result as? [PhotoAlbum] else { return }
            self.albums = albums
            self.updateUI()
        }
    }
    
    private func downloadThumb(forAlbum album: PhotoAlbum, andPlaceOnImageView imageView: UIImageView) {
        
        getPhotos(forAlbumID: album.albumID, ownerID: groupID, offset: 0, count: 1) { (result) in
            
            guard let photos = result as? [Photo] else { return }
            
            guard photos.count > 0 else { return }
            
            let firstPhotoOfAlbum = photos.first
            
            var linkToNeededRes: String?
            var neededRes: PhotoResolution!
            
            if self.scrollViewParams.imageViewHeight < 320 {
                linkToNeededRes = firstPhotoOfAlbum?.photo_604
                neededRes = .res604
            } else {
                linkToNeededRes = firstPhotoOfAlbum?.photo_807
                neededRes = .res807
            }
            
            // Looking for max resolution, if not found yet
            if linkToNeededRes == nil {
                var index = neededRes.rawValue - 1
                
                while index >= PhotoResolution.res75.rawValue {
                    let lessResKey = firstPhotoOfAlbum?.keysResArray[index]
                    let lessResolution = firstPhotoOfAlbum?.resolutionDictionary[lessResKey!]
                    
                    if lessResolution != nil {
                        linkToNeededRes = lessResolution!
                        break
                    }
                    
                    index -= 1
                }
                
                if linkToNeededRes == nil {
                    linkToNeededRes = firstPhotoOfAlbum?.maxRes
                }
            }
            
            let urlPhoto = URL(string: linkToNeededRes!)
            
            imageView.af_setImage(withURL: urlPhoto!)
        }
    }
    
    
    // MARK: - HELPER METHODS
    // MARK: - ScrollViewParams Calculations
    func calculateImageParametersForPhone() {
        
        self.scrollViewParams.scrollViewWidth = scrollView.bounds.size.width
        self.scrollViewParams.scrollViewHeight = scrollView.bounds.size.height
        
        switch self.scrollViewParams.scrollViewWidth {
            
        // *** IPHONE 4s & 5/5s ***
        case 320:
            // iPhone 4s Portrait (320 x 480)
            if self.scrollViewParams.scrollViewHeight == 480 {
                self.scrollViewParams.itemWidth = 320
                self.scrollViewParams.itemHeight = 420
                
                self.scrollViewParams.imageViewWidth = 278
                self.scrollViewParams.imageViewHeight = 370
                
                self.scrollViewParams.titleLabelFont = UIFont.systemFont(ofSize: 16.0)
                
                self.scrollViewParams.columnsPerPage = 1
                
            } else {
                // iPhone 5/5s Portrait (320 x 568)
                self.scrollViewParams.itemWidth = 320
                self.scrollViewParams.itemHeight = 478
                
                self.scrollViewParams.imageViewWidth = 278
                self.scrollViewParams.imageViewHeight = 398
                
                self.scrollViewParams.titleLabelFont = UIFont.systemFont(ofSize: 16.0)
                
                self.scrollViewParams.columnsPerPage = 1
            }
            
        // iPhone 4s Landscape (480 x 320)
        case 480:
            self.scrollViewParams.itemWidth = 160
            self.scrollViewParams.itemHeight = 320
            
            self.scrollViewParams.imageViewWidth = 146
            self.scrollViewParams.imageViewHeight = 240
            
            self.scrollViewParams.titleLabelFont = UIFont.systemFont(ofSize: 12.0)
            
            self.scrollViewParams.columnsPerPage = 3
            
        // iPhone 5/5s Landscape (568 x 320)
        case 568:
            self.scrollViewParams.itemWidth = 189
            self.scrollViewParams.itemHeight = 320
            
            self.scrollViewParams.imageViewWidth = 170
            self.scrollViewParams.imageViewHeight = 260
            
            self.scrollViewParams.titleLabelFont = UIFont.systemFont(ofSize: 14.0)
            
            self.scrollViewParams.columnsPerPage = 3
            
            // *** IPHONE 6/6s/7 ***
        // iPhone 6/6s/7 Portrait (375 x 667)
        case 375:
            self.scrollViewParams.itemWidth = 375
            self.scrollViewParams.itemHeight = 577
            
            self.scrollViewParams.imageViewWidth = 326
            self.scrollViewParams.imageViewHeight = 466
            
            self.scrollViewParams.titleLabelFont = UIFont.systemFont(ofSize: 16.0)
            
            self.scrollViewParams.columnsPerPage = 1
            
        // iPhone 6/6s/7 Landscape (667 x 375)
        case 667:
            self.scrollViewParams.itemWidth = 222
            self.scrollViewParams.itemHeight = 375
            
            self.scrollViewParams.imageViewWidth = 206
            self.scrollViewParams.imageViewHeight = 300
            
            self.scrollViewParams.titleLabelFont = UIFont.systemFont(ofSize: 14.0)
            
            self.scrollViewParams.columnsPerPage = 3
            
            // *** IPHONE PLUS ***
        // iPhone Plus Portrait (414 x 736)
        case 414:
            self.scrollViewParams.itemWidth = 207
            self.scrollViewParams.itemHeight = 318 // (736 - 10 - 40 for pagecontrol - 50 for tabbar) /2
            
            self.scrollViewParams.imageViewWidth = 201
            self.scrollViewParams.imageViewHeight = 308
            
            self.scrollViewParams.columnsPerPage = 2
            self.scrollViewParams.rowsPerPage = 2
            
            self.scrollViewParams.titleLabelFont = UIFont.systemFont(ofSize: 14.0)
            
            self.scrollViewParams.firstRowMarginY = 10
            
        // iPhone Plus Landscape Split Mode (295 x 414)
        case 295:
            self.scrollViewParams.itemWidth = 295
            self.scrollViewParams.itemHeight = 414
            
            self.scrollViewParams.imageViewWidth = 281
            self.scrollViewParams.imageViewHeight = 390
            
            self.scrollViewParams.columnsPerPage = 1
            self.scrollViewParams.rowsPerPage = 1
            
            self.scrollViewParams.titleLabelFont = UIFont.systemFont(ofSize: 16.0)
            
            self.scrollViewParams.firstRowMarginY = 0
            
        // iPhone Plus Landscape WITHOUT SPLIT (736 x 414)
        case 736:
            self.scrollViewParams.itemWidth = 245
            self.scrollViewParams.itemHeight = 414
            
            self.scrollViewParams.imageViewWidth = 229
            self.scrollViewParams.imageViewHeight = 338
            
        default:
            break
        }
    }
    
    func calculateImageParametersForPad() {
        
        self.scrollViewParams.scrollViewWidth = scrollView.bounds.size.width
        self.scrollViewParams.scrollViewHeight = scrollView.bounds.size.height
        
        switch self.scrollViewParams.scrollViewWidth {
            
        // *** iPad Air/Air2/Retina/Pro9.7" ***
        case 320:
            // iPad Air/Air2/Retina/Pro9.7" Portrait Split (320 x 1024)
            if self.scrollViewParams.scrollViewHeight == 1024 {
                self.scrollViewParams.itemWidth = 320
                self.scrollViewParams.itemHeight = 492
                
                self.scrollViewParams.imageViewWidth = 310
                self.scrollViewParams.imageViewHeight = 480
                
                self.scrollViewParams.columnsPerPage = 1
                self.scrollViewParams.rowsPerPage = 2
                
                self.scrollViewParams.titleLabelFont = UIFont.boldSystemFont(ofSize: 15)
                
                self.scrollViewParams.firstRowMarginY = 20
                self.scrollViewParams.lastRowMarginY = 20
                
                // iPad Air/Air2/Retina/Pro9.7" Landscape Split (320 x 768)
            } else {
                self.scrollViewParams.itemWidth = 320
                self.scrollViewParams.itemHeight = 349
                
                self.scrollViewParams.imageViewWidth = 280
                self.scrollViewParams.imageViewHeight = 338
                
                self.scrollViewParams.columnsPerPage = 1
                self.scrollViewParams.rowsPerPage = 2
                
                self.scrollViewParams.titleLabelFont = UIFont.boldSystemFont(ofSize: 15)
                
                self.scrollViewParams.firstRowMarginY = 20
                self.scrollViewParams.lastRowMarginY = 50
            }
            
        // *** iPad Pro12.9" ***
        case 375:
            // iPad Pro12.9" Portrait Split (375 x 1366)
            if self.scrollViewParams.scrollViewHeight == 1366 {
                self.scrollViewParams.itemWidth = 375
                self.scrollViewParams.itemHeight = 442
                
                self.scrollViewParams.imageViewWidth = 340
                self.scrollViewParams.imageViewHeight = 430
                
                self.scrollViewParams.columnsPerPage = 1
                self.scrollViewParams.rowsPerPage = 3
                
                self.scrollViewParams.titleLabelFont = UIFont.boldSystemFont(ofSize: 15)
                
                self.scrollViewParams.firstRowMarginY = 20
                self.scrollViewParams.lastRowMarginY = 20
                
                // iPad Pro12.9" Landscape Split (375 x 1024)
            } else {
                self.scrollViewParams.itemWidth = 375
                self.scrollViewParams.itemHeight = 477
                
                self.scrollViewParams.imageViewWidth = 340
                self.scrollViewParams.imageViewHeight = 460
                
                self.scrollViewParams.columnsPerPage = 1
                self.scrollViewParams.rowsPerPage = 2
                
                self.scrollViewParams.titleLabelFont = UIFont.boldSystemFont(ofSize: 15)
                
                self.scrollViewParams.firstRowMarginY = 20
                self.scrollViewParams.lastRowMarginY = 50
            }
            
        default:
            break
        }
    }
    
    // MARK: - MAIN METHOD. CREATING GALLERY
    private func tileAlbums(albums: [PhotoAlbum]) {
        if isPad {
            self.calculateImageParametersForPad()
        } else {
            self.calculateImageParametersForPhone()
        }
        
        let paddingHorz = (self.scrollViewParams.itemWidth - self.scrollViewParams.imageViewWidth)/2
        
        let paddingVert = (self.scrollViewParams.itemHeight - self.scrollViewParams.imageViewHeight)/2
        
        var row = 0
        var column = 0
        var x: CGFloat = 0
        
        let contentLabelHeight = self.scrollViewParams.itemHeight * 0.12
        
        var firstRowMarginY: CGFloat = self.scrollViewParams.firstRowMarginY
        var lastRowMarginY: CGFloat = 0
        
        for (index, album) in albums.enumerated() {
            
            // Create two WRAPPER UIViews to create shadow effect. Inside wrapper - for cornerRadius (masksToBounds = true). External wrapper - for shadow (masksToBounds = false)
            
            // 1. External WrapView for shadow
            
            let extWrapperRect = CGRect(x: x + paddingHorz,
                                        y: firstRowMarginY + lastRowMarginY + CGFloat(row)*self.scrollViewParams.itemHeight + paddingVert,
                                        width: self.scrollViewParams.imageViewWidth,
                                        height: self.scrollViewParams.imageViewHeight)
            
            let extWrapView = UIView(frame: extWrapperRect)
            
            extWrapView.shadowDesign = true
            
            // 2. Internal WrapView for cornerRadius
            
            let innerWrapperRect = CGRect(x: 0,
                                          y: 0,
                                          width: self.scrollViewParams.imageViewWidth,
                                          height: self.scrollViewParams.imageViewHeight)
            
            let innerWrapView = UIView(frame: innerWrapperRect)
            
            innerWrapView.layer.cornerRadius = 4.0
            innerWrapView.layer.masksToBounds = true
            
            // 3. Album Thumb ImageView
            
            let albumThumbImageView = UIImageView()
            
            albumThumbImageView.contentMode = .scaleAspectFill
            albumThumbImageView.clipsToBounds = true
            
            albumThumbImageView.tag = 2000 + index
            
            albumThumbImageView.frame = CGRect(x: 0,
                                               y: 0,
                                               width: self.scrollViewParams.imageViewWidth,
                                               height: self.scrollViewParams.imageViewHeight)
            
            albumThumbImageView.isUserInteractionEnabled = true
            
            downloadThumb(forAlbum: album, andPlaceOnImageView: albumThumbImageView)
            
            // 4. Blur Effect View with Label with Album Title
            
            let blurEffect = UIBlurEffect(style: .extraLight)
            let visualEffectView = UIVisualEffectView(effect: blurEffect)
            
            visualEffectView.frame = CGRect(x: 0,
                                            y: self.scrollViewParams.imageViewHeight - contentLabelHeight,
                                            width: self.scrollViewParams.imageViewWidth,
                                            height: contentLabelHeight)
            
            let albumTitleLabel = UILabel()
            
            albumTitleLabel.text = album.albumTitle
            albumTitleLabel.tag = 2000 + index
            
            albumTitleLabel.textColor = UIColor.black
            albumTitleLabel.textAlignment = .center
            
            albumTitleLabel.font = self.scrollViewParams.titleLabelFont
            
            albumTitleLabel.numberOfLines = 2
            
            albumTitleLabel.frame = visualEffectView.bounds
            
            albumTitleLabel.isUserInteractionEnabled = true
            
            visualEffectView.contentView.addSubview(albumTitleLabel)
            
            // 5. Adding Tap Gesture Recognizers for albumThumbImageView and albumTitleLabel
            let tapOnImageViewGesture = UITapGestureRecognizer(target: self, action: #selector(self.actionGestureTap))
            let tapOnLabelGesture = UITapGestureRecognizer(target: self, action: #selector(actionGestureTap))
            
            albumThumbImageView.addGestureRecognizer(tapOnImageViewGesture)
            albumTitleLabel.addGestureRecognizer(tapOnLabelGesture)
            
            // 6. Constructing all together.
            innerWrapView.addSubview(albumThumbImageView)
            innerWrapView.addSubview(visualEffectView)
            
            extWrapView.addSubview(innerWrapView)
            
            scrollView.addSubview(extWrapView)
            
            // Handling iPad SplitVC - scroll view vertical mode
            if isPad {
                row += 1
                
                if row % self.scrollViewParams.rowsPerPage == 0 {
                    firstRowMarginY += self.scrollViewParams.firstRowMarginY
                    lastRowMarginY += self.scrollViewParams.lastRowMarginY
                }
                
            } else {
                row += 1
                
                if row == self.scrollViewParams.rowsPerPage {
                    
                    row = 0
                    
                    x += self.scrollViewParams.itemWidth
                    column += 1
                    
                    if column == self.scrollViewParams.columnsPerPage {
                        column = 0
                    }
                }
            }
        }
        
        let imagesPerPage = self.scrollViewParams.columnsPerPage * self.scrollViewParams.rowsPerPage
        
        let numPages = 1 + (albums.count - 1) / imagesPerPage
        
        // Handling iPad SplitVC - scroll view vertical mode
        if isPad {
            scrollView.contentSize = CGSize(
                width: scrollView.bounds.size.width,
                height: CGFloat(numPages)*self.scrollViewParams.scrollViewHeight)
            
        } else {
            scrollView.contentSize = CGSize(
                width: CGFloat(numPages)*self.scrollViewParams.scrollViewWidth,
                height: scrollView.bounds.size.height)
        }
        
        pageControl.numberOfPages = numPages
        pageControl.currentPage = 0
    }
    
    // MARK: - SPLIT VIEW METHODS
    func hideMasterPane() {
        UIView.animate(withDuration: 0.25, animations: {
            self.splitViewController?.preferredDisplayMode = .primaryHidden
        }) { (success) in
            self.splitViewController?.preferredDisplayMode = .automatic
        }
    }
    
    func hideMasterPanePhonePlus() {
        UIView.animate(withDuration: 0.25, animations: {
            self.splitViewController?.preferredDisplayMode = .primaryHidden
        }) { (success) in
            
        }
    }
    
    
    // MARK: - ACTIONS
    @objc func actionGestureTap(_ sender: UITapGestureRecognizer) {
        
        var tappedAlbum: PhotoAlbum?
        
        if let tappedImageView = sender.view as? UIImageView {
            tappedAlbum = self.albums[tappedImageView.tag - 2000]
            
        } else if let tappedLabel = sender.view as? UILabel {
            tappedAlbum = self.albums[tappedLabel.tag - 2000]
        }
        
        if let tappedAlbum = tappedAlbum {
            
            getPhotos(forAlbumID: tappedAlbum.albumID, ownerID: groupID, completed: { (result) in
                
                let photos = result as! [Photo]
                
                if self.view.window!.rootViewController!.traitCollection.horizontalSizeClass == .compact {
                    
                    self.performSegue(withIdentifier: Storyboard.seguePhotoDisplayer, sender: photos)
                    
                } else {
                    if self.isPhonePlus {
                        self.hideMasterPanePhonePlus()
                        
                    } else if self.splitViewController?.displayMode != .allVisible {
                        self.hideMasterPane()
                    }
                    
                    self.splitViewDetail?.currentPhoto = photos[0]
                    self.splitViewDetail?.mediasArray = photos
                    self.splitViewDetail?.currentIndex = 0
                }
            })
        }
    }
    
    @IBAction func pageChanged(sender: UIPageControl) {
        
        // iPhone case only
        UIView.animate(withDuration: 0.3,
                       delay: 0,
                       options: .curveEaseInOut,
                       animations: {
                        self.scrollView.contentOffset = CGPoint(
                            x: self.scrollView.bounds.width * CGFloat(sender.currentPage),
                            y: 0)
        }, completion: nil)
        
    }
    
    // MARK: - NAVIGATION
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == Storyboard.seguePhotoDisplayer {
            let destinationNavVC = segue.destination as! UINavigationController
            //            destinationNavVC.transitioningDelegate = TransitionHelper.sharedHelper.acRotateTransition
            
            let destinationVC = destinationNavVC.topViewController as! PhotoViewController
            
            guard let photos = sender as? [Photo] else { return }
            
            destinationVC.currentPhoto = photos[0]
            destinationVC.mediasArray = photos
            destinationVC.currentIndex = 0
        }
    }
}

// MARK: - UIScrollViewDelegate
extension LandscapeViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if !isPad {
            let width = scrollView.bounds.width
            let currentPage = Int((scrollView.contentOffset.x + width / 2) / width)
            pageControl.currentPage = currentPage
        }
    }
}


extension LandscapeViewController: PhotosProtocol { }

