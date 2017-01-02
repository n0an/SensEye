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
        
        
        scrollView.backgroundColor = UIColor(patternImage: UIImage(named: "LandscapeBackground")!)
        
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
    
    private func downloadThumb(forAlbum album: PhotoAlbum, andPlaceOnButton button: UIButton) {
        
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
//            button.imageView?.af_setImage(withURL: urlPhoto!)
            
            
            
            
            
            
            button.af_setImage(for: .normal, url: urlPhoto!)
            
            
        }
        
        
    }
    
    
    // MARK: - HELPER METHODS
    private func tileButtons(albums: [PhotoAlbum]) {
        
        var columnsPerPage = 3
        var rowsPerPage = 1
        
        var itemWidth: CGFloat = 200
        var itemHeight: CGFloat = 200
        
        var marginX: CGFloat = 0
        var marginY: CGFloat = 20
        
        
        let scrollViewWidth = scrollView.bounds.size.width
        
        switch scrollViewWidth {
            
        case 568:
            columnsPerPage = 3
            itemWidth = 170
            marginX = 2
            
        case 667:
            columnsPerPage = 3
            itemWidth = 222
            itemHeight = 360
            marginX = 1
            marginY = 0
            
        case 736:
            columnsPerPage = 3
            rowsPerPage = 1
            itemWidth = 200
            
        default:
            break
        }
        
        
        let buttonWidth: CGFloat = 206
        let buttonHeight: CGFloat = 340
        let paddingHorz = (itemWidth - buttonWidth)/2
//        let paddingVert = (itemHeight - buttonHeight)/2
        let paddingVert = CGFloat(0)

        
        var row = 0
        var column = 0
        var x = marginX
        
        
        for (index, album) in albums.enumerated() {
            
            let button = UIButton(type: .custom)
            
            button.setBackgroundImage(UIImage(named: "LandscapeButton"), for: .normal)
            
            button.imageView?.contentMode = .scaleAspectFill
//            button.imageView?.clipsToBounds = true
//            button.clipsToBounds = true
            
            button.tag = 2000 + index
            
            button.addTarget(self, action: #selector(LandscapeViewController.buttonPressed(sender:)), for: .touchUpInside)
            
            downloadThumb(forAlbum: album, andPlaceOnButton: button)
            
            button.frame = CGRect(
                x: x + paddingHorz,
                y: marginY + CGFloat(row)*itemHeight + paddingVert,
                width: buttonWidth,
                height: buttonHeight)
            
            
            scrollView.addSubview(button)
            
            row += 1
            
            if row == rowsPerPage {
                
                row = 0; x += itemWidth; column += 1
                
                if column == columnsPerPage {
                    
                    column = 0; x += marginX * 2
                }
            }
        }
        
        let buttonsPerPage = columnsPerPage * rowsPerPage
        
        let numPages = 1 + (albums.count - 1) / buttonsPerPage
        
        scrollView.contentSize = CGSize(
            width: CGFloat(numPages)*scrollViewWidth,
            height: scrollView.bounds.size.height)
        
        print("Number of pages: \(numPages)")
        
        
        
        pageControl.numberOfPages = numPages
        pageControl.currentPage = 0
        
    }

    // MARK: - Show/Hide Spinner
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
    
    // MARK: - ACTIONS
    
    func buttonPressed(sender: UIButton) {
        performSegue(withIdentifier: Storyboard.seguePhotoDisplayer, sender: sender)
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






































