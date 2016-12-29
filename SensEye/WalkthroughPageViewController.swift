//
//  WalkthroughPageViewController.swift
//  FoodPin
//
//  Created by Simon Ng on 18/8/2016.
//  Copyright © 2016 AppCoda. All rights reserved.
//

import UIKit

class WalkthroughPageViewController: UIPageViewController, UIPageViewControllerDataSource {

    var albums: [PhotoAlbum] = []
    

    override func viewDidLoad() {
        super.viewDidLoad()

        dataSource = self
        
        getAlbumsFromServer()
        
        
    }

    func getAlbumsFromServer() {
        ServerManager.sharedManager.getPhotoAlbums(forGroupID: groupID) { (result) in
            
            guard let albums = result as? [PhotoAlbum] else { return }
            
            self.albums = albums
            
            // Create the first walkthrough screen
            if let startingViewController = self.contentViewController(at: 0) {
                self.setViewControllers([startingViewController], direction: .forward, animated: true, completion: nil)
            }
            
        }
    }
    
    
    // MARK: - Helper Methods
    
    func contentViewController(at index: Int) -> WalkthroughContentViewController? {
        if index < 0 || index >= self.albums.count {
            return nil
        }
        
        // Create a new view controller and pass suitable data.
        if let pageContentViewController = storyboard?.instantiateViewController(withIdentifier: "WalkthroughContentViewController") as? WalkthroughContentViewController {
            
            pageContentViewController.index = index
            pageContentViewController.totalAlbums = self.albums.count
            pageContentViewController.album = self.albums[index]
            
            return pageContentViewController
        }
        
        return nil
    }
    
    func forward(index: Int) {
        if let nextViewController = contentViewController(at: index + 1) {
            setViewControllers([nextViewController], direction: .forward, animated: true, completion: nil)
        }
    }
    
    
    // MARK: - UIPageViewControllerDataSource Methods
    
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        var index = (viewController as! WalkthroughContentViewController).index
        index -= 1
        
        return contentViewController(at: index)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        var index = (viewController as! WalkthroughContentViewController).index
        index += 1
        
        return contentViewController(at: index)
    }
    
    

}
