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
import Fabric
import Crashlytics

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UISplitViewControllerDelegate {
    
    var window: UIWindow?
    
    // MARK: - SplitViewController configuration
    var splitViewController: MySplitViewController {
        let rootTabController = window!.rootViewController as! UITabBarController
        
        let splitVC = rootTabController.viewControllers![TabBarIndex.gallery.rawValue] as! MySplitViewController
        
        return splitVC
    }
    
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
        
        FirebaseApp.configure()
        
        Fabric.with([Crashlytics.self])
        
        customizeAppearance()
        
        // FACEBOOK LOGIN
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        
        // GOOGLE LOGIN
        GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
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
        window?.backgroundColor = mainThemeColor
        window?.tintColor = mainTintColor
    }
    
    func readSecretsFile() {
        let filePath = Bundle.main.path(forResource: "secretsFile", ofType: "txt")
        
        guard let secretInfo = try? String(contentsOfFile: filePath!) else { return }
        
        guard secretInfo != "" else { return }
        
        let keys = secretInfo.components(separatedBy: "\n")
        
        GeneralHelper.sharedHelper.appOwnerEmail = keys[0]
        GeneralHelper.sharedHelper.kONESIGNALAPPID = keys[1]
        GeneralHelper.sharedHelper.serviceVKToken = keys[2]
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        var handled = false
        
        if url.absoluteString.contains("fb") {
            handled = FBSDKApplicationDelegate.sharedInstance().application(app, open: url, options: options)
        } else {
            handled = GIDSignIn.sharedInstance().handle(url, sourceApplication: options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String, annotation: [:])
        }
        
        return handled
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

