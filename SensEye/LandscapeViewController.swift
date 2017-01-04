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
    
    fileprivate enum Storyboard {
        
        static let seguePhotoDisplayer = "showPhoto"
        
        static let viewControllerIdPhotoDisplayer = "PhotoNavViewController"
    }
    
    public var albums: [PhotoAlbum] = []
    
    
    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // TURN OFF AUTO LAYOUT FOR DEDICATED VC
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
        
        scrollView.frame = view.bounds
        
        pageControl.frame = CGRect(x: 0,
                                   y: view.frame.size.height - pageControl.frame.size.height,
                                   width: view.frame.size.width,
                                   height: pageControl.frame.size.height)
        
        self.tileAlbums(albums: albums)
  
    }
    
    deinit {
        print("deinit \(self)")
        
    }
    
    // MARK: - API METHODS

    private func downloadThumb(forAlbum album: PhotoAlbum, andPlaceOnImageView imageView: UIImageView) {
        
        ServerManager.sharedManager.getPhotos(forAlbumID: album.albumID, ownerID: groupID, offset: 0, count: 1) { (result) in
            
            guard let photos = result as? [Photo] else { return }
            
            guard photos.count > 0 else { return }
            
            let firstPhotoOfAlbum = photos.first
            
            var linkToNeededRes = firstPhotoOfAlbum?.photo_604
            let neededRes: PhotoResolution = .res604
            
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
    
    // MAIN METHOD. CREATING GALLERY
    private func tileAlbums(albums: [PhotoAlbum]) {
        
        let columnsPerPage = 3
        
        var itemWidth: CGFloat!
        var itemHeight: CGFloat!
        
        let contentLabelHeight: CGFloat = 40
        
        let scrollViewWidth = scrollView.bounds.size.width
        
        var imageViewWidth: CGFloat!
        var imageViewHeight: CGFloat!
        
        switch scrollViewWidth {
            
        case 568:
            
            itemWidth = 189
            itemHeight = 320

            imageViewWidth = 170
            imageViewHeight = 260
            
        case 667:
            
            itemWidth = 222
            itemHeight = 375

            imageViewWidth = 206
            imageViewHeight = 300
            
        case 736:
            
            itemWidth = 245
            itemHeight = 414

            imageViewWidth = 229
            imageViewHeight = 338

        default:
            itemWidth = 222
            itemHeight = 375
            
            imageViewWidth = 206
            imageViewHeight = 300
        }
        
        let paddingHorz = (itemWidth - imageViewWidth)/2
        let paddingVert = (itemHeight - imageViewHeight - contentLabelHeight/2)/2
        
        var x: CGFloat = 0
        
        for (index, album) in albums.enumerated() {
            
            // Create two WRAPPER UIViews to create shadow effect. Inside wrapper - for cornerRadius (masksToBounds = true). External wrapper - for shadow (masksToBounds = false)
            
            // 1. External WrapView for shadow
            
            let extWrapperRect = CGRect(x: x + paddingHorz,
                                        y: paddingVert,
                                        width: imageViewWidth,
                                        height: imageViewHeight)
            
            let extWrapView = UIView(frame: extWrapperRect)
            
            extWrapView.shadowDesign = true
            
            
            // 2. Internal WrapView for cornerRadius
            
            let innerWrapperRect = CGRect(x: 0,
                                          y: 0,
                                          width: imageViewWidth,
                                          height: imageViewHeight)
            
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
                                               width: imageViewWidth,
                                               height: imageViewHeight)
            
            albumThumbImageView.isUserInteractionEnabled = true
            
            downloadThumb(forAlbum: album, andPlaceOnImageView: albumThumbImageView)
            
            // 4. Blur Effect View with Label with Album Title
            
            let blurEffect = UIBlurEffect(style: .extraLight)
            let visualEffectView = UIVisualEffectView(effect: blurEffect)
            
            visualEffectView.frame = CGRect(x: 0,
                                            y: imageViewHeight - contentLabelHeight,
                                            width: imageViewWidth,
                                            height: contentLabelHeight)
            
            
            let albumTitleLabel = UILabel()
            
            albumTitleLabel.text = album.albumTitle
            albumTitleLabel.tag = 2000 + index
            
            albumTitleLabel.textColor = UIColor.black
            albumTitleLabel.textAlignment = .center
            
            albumTitleLabel.font = UIFont.systemFont(ofSize: 14.0)
            
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
            
            
            x += itemWidth

            
        }
        
        let imagesPerPage = columnsPerPage
        
        let numPages = 1 + (albums.count - 1) / imagesPerPage
        
        scrollView.contentSize = CGSize(
            width: CGFloat(numPages)*scrollViewWidth,
            height: scrollView.bounds.size.height)
        
        print("Number of pages: \(numPages)")
        
        
        pageControl.numberOfPages = numPages
        pageControl.currentPage = 0
        
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
    
    
    
    // MARK: - ACTIONS
    
    func actionGestureTap(_ sender: UITapGestureRecognizer) {
        
        var tappedAlbum: PhotoAlbum?
        
        if let tappedImageView = sender.view as? UIImageView {
            
            tappedAlbum = self.albums[tappedImageView.tag - 2000]
            
        } else if let tappedLabel = sender.view as? UILabel {
            
            tappedAlbum = self.albums[tappedLabel.tag - 2000]
        }
        
        if let tappedAlbum = tappedAlbum {
            
            ServerManager.sharedManager.getPhotos(forAlbumID: tappedAlbum.albumID, ownerID: groupID, completed: { (result) in
                
                let photos = result as! [Photo]
                
                self.performSegue(withIdentifier: Storyboard.seguePhotoDisplayer, sender: photos)
            })
        }
    }
    
    @IBAction func pageChanged(sender: UIPageControl) {
        
        UIView.animate(withDuration: 0.3,
                       delay: 0,
                       options: .curveEaseInOut,
                       animations: {
                        self.scrollView.contentOffset = CGPoint(
                            x: self.scrollView.bounds.width * CGFloat(sender.currentPage),
                            y: 0)
        }, completion: nil)
    }
}

extension LandscapeViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let width = scrollView.bounds.width
        
        let currentPage = Int((scrollView.contentOffset.x + width / 2) / width)
        
        pageControl.currentPage = currentPage
    }
}






































