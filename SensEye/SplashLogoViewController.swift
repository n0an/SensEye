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
    
    deinit {
        print("SplashLogoViewController deinit")
    }
    
    /// Does not transition to any other UIViewControllers, SplashViewController only FOR TEST
    func showSplashViewControllerNoPing() {
        
        
        if rootViewController is SplashViewController {
            return
        }
        
        rootViewController?.willMove(toParentViewController: nil)
        rootViewController?.removeFromParentViewController()
        rootViewController?.view.removeFromSuperview()
        rootViewController?.didMove(toParentViewController: nil)
        
        let splashViewController = SplashViewController(tileViewFileName: "Chimes2")
        //    let splashViewController = SplashViewController(tileViewFileName: "dark_crop_1000")
        //    let splashViewController = SplashViewController(tileViewFileName: "float_logo")
        
        
        rootViewController = splashViewController
        splashViewController.pulsing = true
        
        splashViewController.willMove(toParentViewController: self)
        addChildViewController(splashViewController)
        view.addSubview(splashViewController.view)
        splashViewController.didMove(toParentViewController: self)
    }
    
    /// Simulates an API handshake success and transitions to MainApp ViewController
    func showSplashViewController() {
        showSplashViewControllerNoPing()
        
        GeneralHelper.sharedHelper.delay(5.00) {
            self.showMainTabBarController()
        }
    }
    
    
    func showMainTabBarController() {
        
        self.dismiss(animated: false, completion: nil)
        
        
//        guard !(rootViewController is UITabBarController) else { return }
//
//        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//        
//        let mainTabBarController = storyboard.instantiateViewController(withIdentifier: "mainTabBarController") as! UITabBarController
//        
//        mainTabBarController.willMove(toParentViewController: self)
//        
//        addChildViewController(mainTabBarController)
//        
//        if let rootViewController = self.rootViewController {
//            
//            self.rootViewController = mainTabBarController
//            
//            rootViewController.willMove(toParentViewController: nil)
//            
//            transition(from: rootViewController, to: mainTabBarController, duration: 0.55, options: [.transitionCrossDissolve, .curveEaseOut], animations: { () -> Void in
//                
//            }, completion: { _ in
//                mainTabBarController.didMove(toParentViewController: self)
//                rootViewController.removeFromParentViewController()
//                rootViewController.didMove(toParentViewController: nil)
//            })
//        } else {
//            rootViewController = mainTabBarController
//            view.addSubview(mainTabBarController.view)
//            mainTabBarController.didMove(toParentViewController: self)
//        }

        
    }
    
    
    /// Displays the MapViewController
//    func showMenuNavigationViewController() {
//        guard !(rootViewController is MenuNavigationViewController) else { return }
//        
//        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//        let nav =  storyboard.instantiateViewController(withIdentifier: "MenuNavigationController") as! UINavigationController
//        nav.willMove(toParentViewController: self)
//        addChildViewController(nav)
//        
//        if let rootViewController = self.rootViewController {
//            self.rootViewController = nav
//            rootViewController.willMove(toParentViewController: nil)
//            
//            transition(from: rootViewController, to: nav, duration: 0.55, options: [.transitionCrossDissolve, .curveEaseOut], animations: { () -> Void in
//                
//            }, completion: { _ in
//                nav.didMove(toParentViewController: self)
//                rootViewController.removeFromParentViewController()
//                rootViewController.didMove(toParentViewController: nil)
//            })
//        } else {
//            rootViewController = nav
//            view.addSubview(nav.view)
//            nav.didMove(toParentViewController: self)
//        }
//    }
    
    
    override var prefersStatusBarHidden : Bool {
        switch rootViewController  {
        case is SplashViewController:
            return true
        case is UITabBarController:
            return false
        default:
            return false
        }
    }
}
