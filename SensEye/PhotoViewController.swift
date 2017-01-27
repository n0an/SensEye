//
//  PhotoViewController.swift
//  SnappyChatty
//
//  Created by Anton Novoselov on 01/12/2016.
//  Copyright © 2016 Anton Novoselov. All rights reserved.
//

import UIKit
import AlamofireImage
import Social

import DGActivityIndicatorView

class PhotoViewController: UIViewController {
    
    @IBOutlet weak var nextPhotoBarButton: UIBarButtonItem!
    @IBOutlet weak var previousPhotoBarButton: UIBarButtonItem!
    
    // MARK: - PROPERTIES
    
    var currentPhoto: Photo!
    var mediasArray: [Photo]! {
        didSet {
            if mediasArray.count <= 1 {
                nextPhotoBarButton.isEnabled = false
                previousPhotoBarButton.isEnabled = false
            }
        }
    }
    
    var currentIndex: Int!
    
    enum PhotoIteractionDirection {
        case next
        case previous
    }
    
    fileprivate var imageView: UIImageView!
    fileprivate var scrollView: UIScrollView!
    
    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.hidesBarsOnTap = true
        
        title = "Album"
        
        downloadAndSetImage()
        updateUI()

        
    }

    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        super.viewWillDisappear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        
        super.viewDidAppear(animated)

    }
    
    // MARK: - HELPER METHODS
    
    func iterateAndSetPhoto(forDirection direction: PhotoIteractionDirection) -> Photo {
        
        var iteratedPhoto: Photo!
        
        if direction == .next {
            if currentIndex == mediasArray.count - 1 {
                iteratedPhoto = mediasArray.first
                currentIndex = 0
            } else {
                currentIndex! += 1
                iteratedPhoto = mediasArray[currentIndex]
            }
            
        } else {
            if currentIndex == 0 {
                iteratedPhoto = mediasArray.last
                currentIndex = mediasArray.count - 1
            } else {
                currentIndex! -= 1
                iteratedPhoto = mediasArray[currentIndex]
            }
        }
        
        return iteratedPhoto
    }
    
    // MARK: - ACTIONS
    
    @IBAction func actionNextPhotoTap() {
        self.currentPhoto = iterateAndSetPhoto(forDirection: .next)
        imageView.image = nil
        downloadAndSetImage()
        updateUI()
    }
    
    @IBAction func actionPreviosPhotoTap() {
        self.currentPhoto = iterateAndSetPhoto(forDirection: .previous)
        imageView.image = nil

        downloadAndSetImage()
        updateUI()
    }
    
    func showActivityVC(withItems items: [Any]) {
        
        let activityController = UIActivityViewController(activityItems: items, applicationActivities: nil)
        
        let excludedActivities = [
            UIActivityType.postToWeibo,
            .print,
            .addToReadingList,
            .postToVimeo,
            .postToTencentWeibo,
            .openInIBooks,
            .assignToContact
        ]
        
        activityController.excludedActivityTypes = excludedActivities
        
        self.present(activityController, animated: true, completion: nil)
        
        
    }
    
    @IBAction func actionShareTap() {
        
        
        let defaultText = "Фотограф Elena Senseye - vk.com/elena_senseye"
        
        
        
        guard let imageToShare = self.imageView.image else  { return }
        
        
        // Display the share menu
        let shareMenu = UIAlertController(title: nil, message: "Поделиться с помощью", preferredStyle: .actionSheet)
        let twitterAction = UIAlertAction(title: "Twitter", style: UIAlertActionStyle.default) { (action) in
            
            // Check if Twitter is available. Otherwise, display an error message
            guard SLComposeViewController.isAvailable(forServiceType: SLServiceTypeTwitter) else {
                let alertMessage = UIAlertController(title: "Twitter недоступен", message: "Вы не вошли в учетную запись Twitter. Пожалуйста, войдите в свою учетную запись в Настройки > Twitter", preferredStyle: .alert)
                alertMessage.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alertMessage, animated: true, completion: nil)
                
                return
            }
            
            // Display Tweet Composer
            if let tweetComposer = SLComposeViewController(forServiceType: SLServiceTypeTwitter) {
                tweetComposer.setInitialText(defaultText)
                tweetComposer.add(imageToShare)
                self.present(tweetComposer, animated: true, completion: nil)
            }
        }
        
        let facebookAction = UIAlertAction(title: "Facebook", style: UIAlertActionStyle.default) { (action) in
            
            // Check if Facebook is available. Otherwise, display an error message
            guard SLComposeViewController.isAvailable(forServiceType: SLServiceTypeFacebook) else {
                let alertMessage = UIAlertController(title: "Facebook недоступен", message: "Вы не вошли в учетную запись Facebook. Пожалуйста, войдите в свою учетную запись в Настройки > Facebook", preferredStyle: .alert)
                alertMessage.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alertMessage, animated: true, completion: nil)
                
                return
            }
            
            // Display Tweet Composer
            if let fbComposer = SLComposeViewController(forServiceType: SLServiceTypeFacebook) {
                fbComposer.setInitialText("Фотограф Elena Senseye")
//                fbComposer.add(URL(string: "https://www.facebook.com/elena.senseye/"))
                
                fbComposer.add(imageToShare)
                
                self.present(fbComposer, animated: true, completion: nil)
            }
        }
        
        let otherAction = UIAlertAction(title: "Другое", style: .default) { (action) in
            
            self.showActivityVC(withItems: [defaultText, imageToShare])
            
        }
        
        let cancelAction = UIAlertAction(title: "Отмена", style: UIAlertActionStyle.cancel, handler: nil)
        
        shareMenu.addAction(facebookAction)
        shareMenu.addAction(twitterAction)
        shareMenu.addAction(otherAction)
        shareMenu.addAction(cancelAction)
        
        self.present(shareMenu, animated: true, completion: nil)

        
        
        
        
        
        
        
        
    }
    
    
    
    @IBAction func actionCloseButtonTapped() {
        dismiss(animated: true, completion: nil)
    }
    
    func gestureClose() {
        dismiss(animated: true, completion: nil)
    }
    
    
    
    
    // MARK: - DOWNLOAD METHODS

    func downloadAndSetImage() {
        
        // Checking device - iPad or iPhone, to select best resolution
        
        var linkToNeededRes: String!
        
        if traitCollection.horizontalSizeClass == .regular && traitCollection.verticalSizeClass == .regular {
            
            linkToNeededRes = currentPhoto.maxRes
            
        } else {
            
            if currentPhoto.photo_1280 != nil {
                linkToNeededRes = currentPhoto.photo_1280
            } else {
                linkToNeededRes = currentPhoto.maxRes
            }
            
        }
        
        let imageURL = URL(string: linkToNeededRes)
        
        let ratio = CGFloat(currentPhoto.width) / CGFloat(currentPhoto.height)
        
        var rect: CGRect!
        
        if ratio > 1 {
            
            rect = CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.width/ratio)
            
        } else {
            rect = CGRect(x: 0, y: 0, width: view.bounds.height * ratio, height: view.bounds.height)
        }
        
        imageView = UIImageView(frame: rect)
        
        imageView.contentMode = .scaleAspectFit
        
        imageView.af_setImage(withURL: imageURL!, placeholderImage: nil, filter: nil, progress: nil, progressQueue: DispatchQueue.main, imageTransition: UIImageView.ImageTransition.crossDissolve(0.3), runImageTransitionIfCached: true) { (response) in
            
            GeneralHelper.sharedHelper.hideDGSpinner(onView: self.view)
        }
        
    }
    
    // MARK: - UI METHODS
    func updateUI() {
        
        if scrollView != nil && (self.view.subviews.index(of: scrollView) != nil) {
            scrollView.removeFromSuperview()
            scrollView = nil
        }
        
        // take up the whole super view inner content
        scrollView = UIScrollView(frame: view.bounds)
        
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        
        scrollView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        scrollView.backgroundColor =  UIColor.black
        scrollView.contentSize = imageView.bounds.size	// the content size of the scroll view is the image size
        scrollView.delegate = self
        
        // !!!IMPORTANT!!!
        // IF turn on - bug when mixed landscape and portrait photos
//        recenterImage()
        
        // Set up the view hierarchy
        scrollView.addSubview(imageView)
        view.addSubview(scrollView)
        
        GeneralHelper.sharedHelper.showDGSpinnter(withType: .rotatingSquares, onView: self.view, withPosition: .center, andColor: .lightGray)
        
        scrollView.contentOffset = CGPoint(x: 400.0, y: 400.0)
        
        // Set zoom parameters: min/max zoom scale, starting zoom scale
        setZoomParametersForSize(scrollViewSize: scrollView.bounds.size)
        
        // Fit the image on the first launch
        scrollView.zoomScale = scrollView.minimumZoomScale
        
        addGestures()
    }
    
    func addGestures() {
        let rightSwipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(actionPreviosPhotoTap))
        let leftSwipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(actionNextPhotoTap))
        
        let downSwipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(gestureClose))
        let upSwipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(gestureClose))
        
        rightSwipeGesture.direction = .right
        leftSwipeGesture.direction = .left
        upSwipeGesture.direction = .up
        downSwipeGesture.direction = .down
        
        
        scrollView.isUserInteractionEnabled = true
        scrollView.addGestureRecognizer(rightSwipeGesture)
        scrollView.addGestureRecognizer(leftSwipeGesture)
        scrollView.addGestureRecognizer(downSwipeGesture)
        scrollView.addGestureRecognizer(upSwipeGesture)
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
