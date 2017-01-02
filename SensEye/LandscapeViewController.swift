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
    
    fileprivate var firstTime = true
    
    
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
        
        
//        scrollView.backgroundColor = UIColor(patternImage: UIImage(named: "LandscapeBackground")!)
        
        pageControl.numberOfPages = 0
        
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        scrollView.frame = view.bounds
        
        pageControl.frame = CGRect(x: 0,
                                   y: view.frame.size.height - pageControl.frame.size.height,
                                   width: view.frame.size.width,
                                   height: pageControl.frame.size.height)
        
        if firstTime {
            firstTime = false
            getAlbumsFromServer()
            
            showSpinner()
        }
        
        
    }
    
    deinit {
        print("deinit \(self)")
        
        //        for task in downloadTasks {
        //            task.cancel()
        //        }
    }
    
    // MARK: - API METHODS
    func getAlbumsFromServer() {
        ServerManager.sharedManager.getPhotoAlbums(forGroupID: groupID) { (result) in
            
            guard let albums = result as? [PhotoAlbum] else { return }
            
            self.albums = albums
            
            self.hideSpinner()
            
            self.tileButtons(albums: albums)
            
        }
    }
    
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
    private func tileButtons(albums: [PhotoAlbum]) {
        
        var columnsPerPage = 3
        var rowsPerPage = 1
        
        var itemWidth: CGFloat = 200
        var itemHeight: CGFloat = 317
        
        var marginX: CGFloat = 0
        var marginY: CGFloat = 20
        
        let contentLabelHeight: CGFloat = 40
        
        let scrollViewWidth = scrollView.bounds.size.width
        
        switch scrollViewWidth {
            
        case 568:
            columnsPerPage = 3
            itemWidth = 170
            marginX = 2
            
        case 667:
            columnsPerPage = 3
            itemWidth = 222
            itemHeight = 375
            marginX = 1
            marginY = 0
            
        case 736:
            columnsPerPage = 3
            rowsPerPage = 1
            itemWidth = 200
            
        default:
            break
        }
        
        
        let imageViewWidth: CGFloat = 206
        let imageViewHeight: CGFloat = 300
        let paddingHorz = (itemWidth - imageViewWidth)/2
        let paddingVert = (itemHeight - imageViewHeight - contentLabelHeight/2)/2
        
        
        var row = 0
        var column = 0
        var x = marginX
        
        
        for (index, album) in albums.enumerated() {
            
            let imageView = UIImageView()
            
            let contentLabel = UILabel()
            
            imageView.contentMode = .scaleAspectFill
            imageView.clipsToBounds = true
            
            imageView.tag = 2000 + index
            
            // Create two WRAPPER UIViews to create shadow effect. Inside wrapper - for cornerRadius (masksToBounds = true). External wrapper - for shadow (masksToBounds = false)
            
            

            
            let insideWrapperRect = CGRect(x: x + paddingHorz,
                                           y: marginY + CGFloat(row) * itemHeight + paddingVert,
                                           width: imageViewWidth,
                                           height: imageViewHeight)
            
            
            let insideWrapperView = UIView(frame: insideWrapperRect)
            
            insideWrapperView.layer.cornerRadius = 20.0
            insideWrapperView.layer.masksToBounds = true
            
            let outsideWrapperView = UIView(frame: insideWrapperView.bounds)
            outsideWrapperView.shadowDesign = true
            
            
            
            imageView.frame = CGRect(
                x: 0,
                y: 0,
                width: imageViewWidth,
                height: imageViewHeight)
            
            downloadThumb(forAlbum: album, andPlaceOnImageView: imageView)

            
            
            
            let blurEffect = UIBlurEffect(style: .extraLight)
            let visualEffectView = UIVisualEffectView(effect: blurEffect)
            
            visualEffectView.frame = CGRect(x: 0,
                                            y: imageViewHeight - contentLabelHeight,
                                            width: imageViewWidth,
                                            height: contentLabelHeight)
            
            
            //            contentLabel.frame = CGRect(x: x + paddingHorz,
            //                                        y: marginY + CGFloat(row)*itemHeight + paddingVert + imageViewHeight,
            //                                        width: imageViewWidth,
            //                                        height: contentLabelHeight)
            
            
            contentLabel.frame = visualEffectView.bounds
            
            visualEffectView.contentView.addSubview(contentLabel)
            
            
            contentLabel.text = album.albumTitle
            contentLabel.textColor = UIColor.black
            contentLabel.textAlignment = .center
            
            //            contentLabel.font = UIFont(name: "AvenirNext-Regular", size: 14.0)
            contentLabel.font = UIFont.systemFont(ofSize: 14.0)
            
            contentLabel.numberOfLines = 2
            
            imageView.isUserInteractionEnabled = true
            contentLabel.isUserInteractionEnabled = true
            
            let tapOnImageViewGesture = UITapGestureRecognizer(target: self, action: #selector(self.actionGestureTap))
            let tapOnLabelGesture = UITapGestureRecognizer(target: self, action: #selector(actionGestureTap))
            
            let tapOnInsideViewGesture = UITapGestureRecognizer(target: self, action: #selector(self.actionGestureTap))
            let tapOnOutsideViewGesture = UITapGestureRecognizer(target: self, action: #selector(self.actionGestureTap))

            
            imageView.addGestureRecognizer(tapOnImageViewGesture)
            contentLabel.addGestureRecognizer(tapOnLabelGesture)
            
            insideWrapperView.isUserInteractionEnabled = true
            insideWrapperView.addGestureRecognizer(tapOnInsideViewGesture)
            
            outsideWrapperView.isUserInteractionEnabled = true
            outsideWrapperView.addGestureRecognizer(tapOnOutsideViewGesture)
            
            insideWrapperView.addSubview(imageView)
            insideWrapperView.addSubview(visualEffectView)
            
            outsideWrapperView.addSubview(insideWrapperView)

            
//            scrollView.addSubview(imageView)
//            scrollView.addSubview(visualEffectView)
            
            scrollView.addSubview(outsideWrapperView)
            
            row += 1
            
            if row == rowsPerPage {
                
                print("x = \(x)")

                
                row = 0
                x += itemWidth
                column += 1
                
                if column == columnsPerPage {
                    
                    column = 0
                    x += marginX * 2
                }
                
                print("x = \(x)")

            }
            
            print("x = \(x)")
            
        }
        
        let imagesPerPage = columnsPerPage * rowsPerPage
        
        let numPages = 1 + (albums.count - 1) / imagesPerPage
        
        scrollView.contentSize = CGSize(
            width: CGFloat(numPages)*scrollViewWidth,
            height: scrollView.bounds.size.height)
        
        print("Number of pages: \(numPages)")
        
        
        pageControl.numberOfPages = numPages
        pageControl.currentPage = 0
        
    }
    
    private func showSpinner() {
        let spinner = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        spinner.center = CGPoint(x: scrollView.bounds.width / 2 + 0.5, y: scrollView.bounds.height / 2 + 0.5)
        spinner.tag = 1000
        view.addSubview(spinner)
        spinner.startAnimating()
    }
    
    private func hideSpinner() {
        view.viewWithTag(1000)?.removeFromSuperview()
    }
    
    
    
    // MARK: - NAVIGATION
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Storyboard.seguePhotoDisplayer {
            
            let destinationNavVC = segue.destination as! UINavigationController
            destinationNavVC.transitioningDelegate = TransitionHelper.sharedHelper.acRotateTransition
            
            let destinationVC = destinationNavVC.topViewController as! PhotoViewController
            
            guard let photos = sender as? [Photo] else { return }
            
            destinationVC.currentPhoto = photos[0]
            destinationVC.mediasArray = photos
            destinationVC.currentIndex = 0
            
            
        }
    }
    
    
    
    // MARK: - ACTIONS
    
    func actionGestureTap(_ sender: UITapGestureRecognizer) {
        
        guard let outsideWrapperView = sender.view else {
            return
        }
        
        print("outsideWrapperView.subview = \(outsideWrapperView.subviews)")
        
        let insdieWrapperView = outsideWrapperView.subviews[0]
        
        guard let tappedImageView = insdieWrapperView.subviews[0] as? UIImageView else { return }
        
        let tappedAlbum = self.albums[tappedImageView.tag - 2000]
        
        ServerManager.sharedManager.getPhotos(forAlbumID: tappedAlbum.albumID, ownerID: groupID, completed: { (result) in
            
            let photos = result as! [Photo]
            
            self.performSegue(withIdentifier: Storyboard.seguePhotoDisplayer, sender: photos)
            
            
            
            
        })
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
        
//        self.scrollView.contentOffset = CGPoint(
//            x: self.scrollView.bounds.width * CGFloat(sender.currentPage),
//            y: 0)
        
    }
    
    
    
    
    
}



extension LandscapeViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let width = scrollView.bounds.width
        
        let currentPage = Int((scrollView.contentOffset.x + width / 2) / width)
        
        pageControl.currentPage = currentPage
        
    }
    
}






































