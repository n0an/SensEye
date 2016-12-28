//
//  PhotoViewController.swift
//  SnappyChatty
//
//  Created by Anton Novoselov on 01/12/2016.
//  Copyright © 2016 Anton Novoselov. All rights reserved.
//

import UIKit
import AlamofireImage

class PhotoViewController: UIViewController {
    
    // MARK: - PROPERTIES
    
    var currentPhoto: Photo!
    var mediasArray: [Any]!
    var currentIndex: Int!
    
    // MARK: - Private
    fileprivate var imageView: UIImageView!
    fileprivate var scrollView: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.hidesBarsOnTap = true
        
        title = "TITLE"
        
        downloadAndSetImage()
        updateUI()

        
    }
    
    func downloadAndSetImage() {
        let imageURL = URL(string: currentPhoto.photo_1280!)
        
        let ratio = CGFloat(currentPhoto.width) / CGFloat(currentPhoto.height)
        
        var rect: CGRect!
        
        if ratio > 1 {
            
            rect = CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.width/ratio)
            
        } else {
            rect = CGRect(x: 0, y: 0, width: view.bounds.height * ratio, height: view.bounds.height)
        }
        
        imageView = UIImageView(frame: rect)
        
        imageView.contentMode = .scaleAspectFit
        
        imageView.af_setImage(withURL: imageURL!, placeholderImage: nil, filter: nil, progress: nil, progressQueue: DispatchQueue.main, imageTransition: UIImageView.ImageTransition.crossDissolve(0.4), runImageTransitionIfCached: true) { (response) in

        }

    }
    
    func updateUI() {
        // take up the whole super view inner content
        scrollView = UIScrollView(frame: view.bounds)
        scrollView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        scrollView.backgroundColor =  UIColor.black
        scrollView.contentSize = imageView.bounds.size	// the content size of the scroll view is the image size
        scrollView.delegate = self
        
        recenterImage()
        
        // Set up the view hierarchy
        scrollView.addSubview(imageView)
        view.addSubview(scrollView)
        
        scrollView.contentOffset = CGPoint(x: 400.0, y: 400.0)
        
        // Set zoom parameters: min/max zoom scale, starting zoom scale
        setZoomParametersForSize(scrollViewSize: scrollView.bounds.size)
        
        // Fit the image on the first launch
        scrollView.zoomScale = scrollView.minimumZoomScale
    }
    
    func recenterImage() {
        
        let scrollViewSize = scrollView.bounds.size
        let imageSize = imageView.frame.size
        
        let horizontalSpace = imageSize.width < scrollViewSize.width ? (scrollViewSize.width - imageSize.width) / 2 : 0
        let verticalSpace = imageSize.height < scrollViewSize.height ? (scrollViewSize.height - imageSize.height) / 2 : 0
        
        // Set the content inset
        scrollView.contentInset = UIEdgeInsets(top: verticalSpace, left: horizontalSpace, bottom: verticalSpace, right: horizontalSpace)
    }
    
    func setZoomParametersForSize(scrollViewSize: CGSize) {
        let imageSize = imageView.bounds.size // we want the size of the bounds that never change
        // the size of the frame will change as we zoom
        
        let widthScale = scrollViewSize.width / imageSize.width
        let heightScale = scrollViewSize.height / imageSize.height
        let minScale = min(widthScale, heightScale)
        
        scrollView.minimumZoomScale = minScale
        scrollView.maximumZoomScale = 3.0
        
    }
    
    // after the rotation
    
    override func viewWillLayoutSubviews() {
        setZoomParametersForSize(scrollViewSize: scrollView.bounds.size)	// to determine landscape or portrait
        
        // If the device is in landscape again
        if scrollView.zoomScale < scrollView.minimumZoomScale {
            scrollView.zoomScale = scrollView.minimumZoomScale
        }
        
        recenterImage()
    }
}

extension PhotoViewController : UIScrollViewDelegate {
    
    // ZOOMING
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        // when the user finish zooming, we would want to check if we want to recenter
        // the image or not
        recenterImage()
    }
    
    // The image view is the subview of the scroll view that it should zoom
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    
}
