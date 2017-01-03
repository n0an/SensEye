


import UIKit

class AlbumsPageViewController: UIPageViewController, UIPageViewControllerDataSource {

    // MARK: - PROPERTIES
    var albums: [PhotoAlbum] = []
    
    enum ContentControllerCyclingDirection {
        case forward
        case backward
    }
    
    var landscapeViewController: LandscapeViewController?
    
    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()

        dataSource = self
        
        getAlbumsFromServer()
        
    }

    // MARK: - API METHODS
    func getAlbumsFromServer() {
        ServerManager.sharedManager.getPhotoAlbums(forGroupID: groupID) { (result) in
            
            guard let albums = result as? [PhotoAlbum] else { return }
            
            self.albums = albums
            
            // Create the first content screen
            if let startingViewController = self.contentViewController(at: 0) {
                self.setViewControllers([startingViewController], direction: .forward, animated: true, completion: nil)
            }
            
        }
    }
    
    
    // MARK: - HELPER METHODS
    
    func contentViewController(at index: Int) -> AlbumsContentViewController? {
        if index < 0 || index >= self.albums.count {
            return nil
        }
        
        // Create a new view controller and pass suitable data.
        if let pageContentViewController = storyboard?.instantiateViewController(withIdentifier: "AlbumsContentViewController") as? AlbumsContentViewController {
            
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
    
    func showViewController(forIndex index: Int, andDirection direction: ContentControllerCyclingDirection) {
        
        if let viewController = contentViewController(at: index) {
            
            if direction == .forward {
                setViewControllers([viewController], direction: .forward, animated: true, completion: nil)
            } else {
                setViewControllers([viewController], direction: .reverse, animated: true, completion: nil)
            }
        }
        
    }
    
    
    // MARK: - UIPageViewControllerDataSource
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        var index = (viewController as! AlbumsContentViewController).index
        index -= 1
        
        return contentViewController(at: index)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        var index = (viewController as! AlbumsContentViewController).index
        index += 1
        
        return contentViewController(at: index)
    }
    
    
    

}



// MARK: - LANDSCAPE MODE

extension AlbumsPageViewController {
    
    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        
        super.willTransition(to: newCollection, with: coordinator)
        
        let rect = UIScreen.main.bounds
        
        
        
        if UIDevice.current.userInterfaceIdiom != .pad {
            
            switch newCollection.verticalSizeClass {
            case .compact:
                showLandscapeViewWithCoordinator(coordinator)
            case .regular, .unspecified:
                hideLandscapeViewWithCoordinator(coordinator)
                
            }
            
        }
        
        // TODO: - Uncomment when implement split view. Comment ^^^
        /*
        // iPhone 6 Plus handler
        if (rect.width == 736 && rect.height == 414) || (rect.width == 414 && rect.height == 736)  {
            if presentedViewController != nil {
                dismiss(animated: true, completion: nil)
            }
        } else if UIDevice.current.userInterfaceIdiom != .pad {
            
            switch newCollection.verticalSizeClass {
            case .compact:
                showLandscapeViewWithCoordinator(coordinator)
            case .regular, .unspecified:
                hideLandscapeViewWithCoordinator(coordinator)
                
            }
            
        }
        */

    }
    
    
    func showLandscapeViewWithCoordinator(_ coordinator: UIViewControllerTransitionCoordinator) {
        
        precondition(landscapeViewController == nil)
        
        landscapeViewController = storyboard!.instantiateViewController(withIdentifier: "LandscapeViewController") as? LandscapeViewController
        
        if let controller = landscapeViewController {
            
            // VIEW CONTROLLER CONTAINMENT
            controller.albums = albums
            
            controller.view.frame = view.bounds
            
            controller.view.alpha = 0
            
            // Hide tabBar
            self.tabBarController?.tabBar.layer.zPosition = -1
            self.tabBarController?.tabBar.isUserInteractionEnabled = false

            view.addSubview(controller.view)
            addChildViewController(controller)
            
            coordinator.animate(alongsideTransition: { _ in
                
                // Close modal VC upon current VC
//                if self.presentedViewController != nil {
//                    self.dismiss(animated: true, completion: nil)
//                }
                
                controller.view.alpha = 1
                
            }, completion: { _ in
                controller.didMove(toParentViewController: self)
            })
            
        }
        
    }
    
    func hideLandscapeViewWithCoordinator(_ coordinator: UIViewControllerTransitionCoordinator) {
        
        if let controller = landscapeViewController {
            
            // Show tabBar
            self.tabBarController?.tabBar.layer.zPosition = 0
            self.tabBarController?.tabBar.isUserInteractionEnabled = true
            
            controller.willMove(toParentViewController: nil)
            
            coordinator.animate(alongsideTransition: { _ in
                
//                if self.presentedViewController != nil {
//                    self.dismiss(animated: true, completion: nil)
//                }
                
                controller.view.alpha = 0
            }, completion: { _ in
                controller.view.removeFromSuperview()
                
                controller.removeFromParentViewController()
                
                self.landscapeViewController = nil
            })
            
            
        }
    }

    
    
    
    
}


























