

import UIKit
import SAMCache

class AlbumsContentViewController: UIViewController {
    
    // MARK: - OUTLETS
//    @IBOutlet var headingLabel: UILabel!
    @IBOutlet var contentLabel: UILabel!
    @IBOutlet var contentImageView: UIImageView!
    @IBOutlet var pageControl: UIPageControl!
//    @IBOutlet var forwardButton: UIButton!
    
//    @IBOutlet weak var visualEffectView: UIVisualEffectView!
    
    
    // MARK: - PROPERTIES
    enum Storyboard {
        static let cellId = "FeedCell"
        static let rowHeight: CGFloat = 370
        
        static let seguePhotoDisplayer = "showPhoto"
    }
    
    var index = 0
    var heading = ""
    var imageFile = ""
    var content = ""
    var totalAlbums: Int!
    
    var currentPage: Int!
    
    var album: PhotoAlbum!
    
    var cache = SAMCache.shared()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pageControl.numberOfPages = totalAlbums
        
        updateUI()
        
        let tapOnImageViewGesture = UITapGestureRecognizer(target: self, action: #selector(actionGestureTap))
        let tapOnLabelGesture = UITapGestureRecognizer(target: self, action: #selector(actionGestureTap))
        self.contentImageView.addGestureRecognizer(tapOnImageViewGesture)
        self.contentLabel.addGestureRecognizer(tapOnLabelGesture)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
     
    }
    
    // MARK: - HELPER METHODS
    func updateUI() {
        
        pageControl.currentPage = index
        
        self.currentPage = index
        
        contentLabel.text = self.album.albumTitle

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
            
            // OLD WAY:
//            self.contentImageView.af_setImage(withURL: urlPhoto!)
            
            
            // NEW WAY WITH CACHING:
            let albumThumbCacheKey = "GalleryThumb-\(self.album.albumID!)"
            
            if let cachedImage = self.cache?.object(forKey: albumThumbCacheKey) as? UIImage {
                self.contentImageView.image = cachedImage
            } else {
                
                
                let session = URLSession.shared
                
                let downloadTask = session.downloadTask(with: urlPhoto!) { [weak self] (localFile, response, error) -> Void in
                    
                    if error == nil && localFile != nil {
                        
                        if let data = try? Data(contentsOf: urlPhoto!) {
                            
                            if let downloadedImage = UIImage(data: data) {
                                
                                DispatchQueue.main.async {
                                    if let strongSelf = self {
                                        
                                        strongSelf.cache?.setObject(downloadedImage, forKey: albumThumbCacheKey)
                                        
                                        strongSelf.contentImageView.image = downloadedImage
                                        

                                    }
                                }
                                
                                
                            }
                        }
                    }
                }
                
                downloadTask.resume()
                
                
              
            }
            
            
            
        }
        
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
    
    func actionGestureTap() {
        
        ServerManager.sharedManager.getPhotos(forAlbumID: self.album.albumID, ownerID: groupID, completed: { (result) in
            
            let photos = result as! [Photo]
            
            self.performSegue(withIdentifier: Storyboard.seguePhotoDisplayer, sender: photos)
        })
    }
    
    
    @IBAction func nextButtonTapped(sender: UIButton) {
        
        let pageViewController = parent as! AlbumsPageViewController
        pageViewController.forward(index: index)
    }
    
    
    
    @IBAction func pageChanged(_ sender: UIPageControl) {
        
        let pageViewController = parent as! AlbumsPageViewController
        
        
        if sender.currentPage > index {
            pageViewController.showViewController(forIndex: sender.currentPage, andDirection: .forward)
        } else {
            pageViewController.showViewController(forIndex: sender.currentPage, andDirection: .backward)
        }
        
    }
    
}














