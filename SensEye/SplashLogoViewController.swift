//
//  SplashLogoViewController.swift
//  SensEye
//
//  Created by Anton Novoselov on 03/02/2017.
//  Copyright © 2017 Anton Novoselov. All rights reserved.
//


import UIKit
import SplashScreenUI

class SplashLogoViewController: UIViewController {
    
    fileprivate var rootViewController: UIViewController? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        showSplashViewControllerNoPing()
            showSplashViewController()
    }
    
    override var shouldAutorotate: Bool {
        return false
    }
    
    deinit {
        print("SplashLogoViewController deinit")
    }
    
    // Does not transition to any other UIViewControllers, SplashViewController only FOR TEST
    func showSplashViewControllerNoPing() {
        
        if rootViewController is SplashViewController {
            return
        }
        
        rootViewController?.willMove(toParentViewController: nil)
        rootViewController?.removeFromParentViewController()
        rootViewController?.view.removeFromSuperview()
        rootViewController?.didMove(toParentViewController: nil)
        
        let splashViewController = SplashViewController(tileViewFileName: "Chimes2")
        
        rootViewController = splashViewController
        splashViewController.pulsing = true
        
        splashViewController.willMove(toParentViewController: self)
        addChildViewController(splashViewController)
        view.addSubview(splashViewController.view)
        splashViewController.didMove(toParentViewController: self)
    }
    
    // transitions to FeedVC
    func showSplashViewController() {
        showSplashViewControllerNoPing()
        
        GeneralHelper.sharedHelper.delay(4.00) {
            self.showMainTabBarController()
        }
    }
    
    
    func showMainTabBarController() {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        let mainTabBarController = storyboard.instantiateViewController(withIdentifier: "mainTabBarController") as! UITabBarController


        UIApplication.shared.keyWindow?.rootViewController = mainTabBarController
     
        
    }
    
    
    
    
    
    
    override var prefersStatusBarHidden : Bool {
        
        return true
        
//        switch rootViewController  {
//        case is SplashViewController:
//            return true
//        case is UITabBarController:
//            return false
//        default:
//            return false
//        }
    }
}
