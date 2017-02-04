//
//  AppDelegate.swift
//  SensEye
//
//  Created by Anton Novoselov on 25/12/2016.
//  Copyright © 2016 Anton Novoselov. All rights reserved.
//

import UIKit
import Firebase
import OneSignal

import FBSDKCoreKit

import GoogleSignIn

import SwiftKeychainWrapper

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UISplitViewControllerDelegate {

    var window: UIWindow?
    
    // MARK: - SplitViewController configuration
    
    lazy var splitViewController: MySplitViewController = { () -> MySplitViewController in
    
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        let rootTabController = storyboard.instantiateViewController(withIdentifier: "mainTabBarController") as! UITabBarController
        
        let splitVC = rootTabController.viewControllers![TabBarIndex.gallery.rawValue] as! MySplitViewController
        
        return splitVC
    
    
    }()
    
    
    var galleryMasterVC: LandscapeViewController {
        return splitViewController.viewControllers.first as! LandscapeViewController
    }
    
    var detailPhotoNavVC: UINavigationController {
        return splitViewController.viewControllers.last as! UINavigationController
    }
    
    var detailPhotoVC: PhotoViewController {
        return detailPhotoNavVC.topViewController as! PhotoViewController
    }
    
    
    func splitViewController(_ svc: UISplitViewController, willChangeTo displayMode: UISplitViewControllerDisplayMode) {
        print(#function)
        if displayMode == .primaryOverlay {
            svc.dismiss(animated: true, completion: nil)
        }
    }
    
    
    // MARK: - didFinishLaunchingWithOptions
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        if !UserDefaults.standard.bool(forKey: APP_FIRST_RUN) {
            
            clearKeychainOnFirstRun()
            
            UserDefaults.standard.set(true, forKey: APP_FIRST_RUN)
            UserDefaults.standard.synchronize()
            
        }
        
        readSecretsFile()
        
        FIRApp.configure()
        
        window?.backgroundColor = mainThemeColor
        
        customizeAppearance()
        
   
        // FACEBOOK LOGIN
        
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        
        
        // GOOGLE LOGIN
        
        GIDSignIn.sharedInstance().clientID = FIRApp.defaultApp()?.options.clientID
        GIDSignIn.sharedInstance().delegate = FRAuthManager.sharedManager
        
        
        // OneSignal Configuration
        
        OneSignal.initWithLaunchOptions(launchOptions, appId: GeneralHelper.sharedHelper.kONESIGNALAPPID, handleNotificationReceived: nil, handleNotificationAction: nil, settings: [kOSSettingsKeyInAppAlerts: false])
        
        
        OneSignal.setLogLevel(ONE_S_LOG_LEVEL.LL_NONE, visualLevel: ONE_S_LOG_LEVEL.LL_NONE)
        
        // Split View Controller Configuration:
        detailPhotoVC.navigationItem.leftBarButtonItem = splitViewController.displayModeButtonItem
        galleryMasterVC.splitViewDetail = detailPhotoVC
        splitViewController.delegate = self
        
        return true
    }
    
    // MARK: - HELPER METHODS
    
    func clearKeychainOnFirstRun() {
        let _ = KeychainWrapper.standard.removeAllKeys()
    }
    
    func customizeAppearance() {
        
        window!.tintColor = UIColor(red: 10/255, green: 80/255, blue: 80/255, alpha: 1)
        
        // NavigationBar Customization
//        UINavigationBar.appearance().barTintColor = UIColor.black
//
//        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
//        UINavigationBar.appearance().tintColor = UIColor.white
        
        
        // TabBar Customization

        // UITabBar.appearance().barTintColor = UIColor.black
        
        // let tintColor = UIColor(red: 255/255.0, green: 238/255.0, blue: 136/255.0, alpha: 1.0)
        
        // UITabBar.appearance().tintColor = tintColor
        
    }
    
    func readSecretsFile() {
        
        let filePath = Bundle.main.path(forResource: "secretsFile", ofType: "txt")
        
        guard let secretInfo = try? String(contentsOfFile: filePath!) else { return }
        
        guard secretInfo != "" else { return }
        
        let keys = secretInfo.components(separatedBy: "\n")
        
        GeneralHelper.sharedHelper.appOwnerEmail = keys[0]
        GeneralHelper.sharedHelper.kONESIGNALAPPID = keys[1]
       
    }
    
    
    // ** Getting current Top ViewController
    func viewControllerForShowingAlert() -> UIViewController {
        
        let rootViewController = self.window!.rootViewController!
        
        if let presentedViewController = rootViewController.presentedViewController {
            
            return presentedViewController
            
        } else {
            
            return rootViewController
        }
        
    }
 
    
    
    // MARK: - FACEBOOK OR GOOGLE LOGIN
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        
        let fbResult = FBSDKApplicationDelegate.sharedInstance().application(app, open: url, sourceApplication: options[UIApplicationOpenURLOptionsKey.sourceApplication] as! String, annotation: options[UIApplicationOpenURLOptionsKey.annotation])
        
        let googleResult = GIDSignIn.sharedInstance().handle(url, sourceApplication: options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String, annotation: [:])
        
        
        return fbResult || googleResult
    }
    
    
    

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

