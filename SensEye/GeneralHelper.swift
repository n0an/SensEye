//
//  GeneralHelper.swift
//  SensEye
//
//  Created by Anton Novoselov on 30/12/2016.
//  Copyright © 2016 Anton Novoselov. All rights reserved.
//

import UIKit
import DGActivityIndicatorView

class GeneralHelper {
    
    // MARK: - PROPERTIES
    public enum DGSpinnerPosition {
        case left
        case right
        case center
        case top
        case bottom
    }
    
    private static let _sharedHelper = GeneralHelper()
    
    static var sharedHelper: GeneralHelper {
        return _sharedHelper
    }
    
    public var kONESIGNALAPPID = ""
    public var appOwnerEmail = ""
    public var serviceVKToken = ""    
    
    // MARK: - SPINNERS
    public func showSpinner(onView view: UIView, usingBoundsFromView viewForBounds: UIView) {
        let spinner = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        spinner.center = CGPoint(x: viewForBounds.bounds.width / 2 + 0.5, y: viewForBounds.bounds.height / 2 + 0.5)
        spinner.tag = 1000
        view.addSubview(spinner)
        spinner.startAnimating()
    }
    
    public func hideSpinner(onView view: UIView) {
        view.viewWithTag(1000)?.removeFromSuperview()
    }
    
    
    public func showDGSpinnter(withType spinnerType: DGActivityIndicatorAnimationType, onView view: UIView, withPosition: DGSpinnerPosition, andColor: UIColor, offsetX: CGFloat = 0, offsetY: CGFloat = 0) {
        
        let dgSpinner = DGActivityIndicatorView(type: spinnerType, tintColor: andColor, size: 50)
        
        dgSpinner?.tag = 1001
        
        var x: CGFloat
        var y: CGFloat
        
        switch withPosition {
        case .center:
            x = view.bounds.midX
            y = view.bounds.midY
            
        case .left:
            x = view.bounds.minX + dgSpinner!.size/2
            y = view.bounds.midY

        case .right:
            x = view.bounds.maxX - dgSpinner!.size/2
            y = view.bounds.midY

        case .top:
            x = view.bounds.midX
            y = view.bounds.minY + dgSpinner!.size/2

        case .bottom:
            x = view.bounds.midX
            y = view.bounds.maxY - dgSpinner!.size/2
        }
        
        dgSpinner?.center = CGPoint(x: x + offsetX, y: y + offsetY)
        
        view.addSubview(dgSpinner!)
        dgSpinner?.startAnimating()
    }
    
    public func hideDGSpinner(onView view: UIView) {
        if let dgSpinner = view.viewWithTag(1001) as? DGActivityIndicatorView {
            dgSpinner.stopAnimating()
            view.viewWithTag(1001)?.removeFromSuperview()
        }
    }
    
    // MARK: - VK AUTHORIZATIONS WARNINGS
    public func showVKAuthorizeActionSheetOnViewController(viewController: UIViewController, completion: @escaping (Bool) -> Void) {
        
        let actionSheet = UIAlertController(title: NSLocalizedString("Authorization to VK required", comment: "VK Login"),
                                            message: NSLocalizedString("You have to login to VK to get access to likes and comments features. You have to login just once", comment: "VK Login"),
                                            preferredStyle: .actionSheet)
        
        let okAction = UIAlertAction(title: "OK", style: .default) { (action) in
            
            completion(true)
        }
        
        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel"), style: .cancel) { (action) in
            completion(false)
        }
        
        actionSheet.addAction(okAction)
        actionSheet.addAction(cancelAction)
        
        actionSheet.popoverPresentationController?.sourceView = viewController.view
        
        viewController.present(actionSheet, animated: true, completion: nil)
    }
    
    public func showLogoutView(onViewController viewController: UIViewController, withHandler handler: @escaping (_ success: Bool) -> Void) {
        
        let optionMenu = UIAlertController(title: NSLocalizedString("Logout?", comment: "Logout?"),
                                           message: nil,
                                           preferredStyle: .actionSheet)
        
        let logOut = UIAlertAction(title: NSLocalizedString("Log Out", comment: "Log Out"), style: .destructive) { (alert: UIAlertAction!) in
            
            handler(true)
        }
        
        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel"), style: .cancel) { (alert: UIAlertAction!) in
        }
        
        optionMenu.addAction(logOut)
        optionMenu.addAction(cancelAction)
        
        optionMenu.popoverPresentationController?.sourceView = viewController.view
        
        viewController.present(optionMenu, animated: true, completion: nil)
    }
    
    // MARK: - PAUSE METHODS
    public func pauseApp(forTimeInMs timeMs: Int) {
        
        // ** Avoid multiple calls of method
        UIApplication.shared.beginIgnoringInteractionEvents()
        
        let deadLineTime = DispatchTime.now() + .milliseconds(timeMs)
        
        DispatchQueue.main.asyncAfter(deadline: deadLineTime) {
            if UIApplication.shared.isIgnoringInteractionEvents {
                UIApplication.shared.endIgnoringInteractionEvents()
            }
        }
    }
    
    public func invoke(afterTimeInMs timeMs: Int, code: @escaping ()->()) {
        let deadLineTime = DispatchTime.now() + .milliseconds(timeMs)
        DispatchQueue.main.asyncAfter(deadline: deadLineTime, execute: code)
    }
    
    public func delay(_ delay:Double, closure:@escaping ()->()) {
        DispatchQueue.main.asyncAfter(
            deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: closure)
    }
    
    
    // MARK: - OTHER METHODS
    public func showAlertOnViewController(viewController: UIViewController, withTitle title: String, message: String, buttonTitle: String) {
        
        let alertVC = UIAlertController(title: title,
                                        message: message,
                                        preferredStyle: .alert)
        
        let action = UIAlertAction(title: buttonTitle,
                                   style: .default,
                                   handler: nil)
        alertVC.addAction(action)
        viewController.present(alertVC, animated: true, completion: nil)
    }
    
    
    func getImageFromURL(urlString: String, withBlock: @escaping (_ image: UIImage?) -> Void) {
        
        let url = URL(string: urlString)
        
        let downloadQueue = DispatchQueue(label: "imageDownloadQueue")
        
        downloadQueue.async {
            
            if let data = try? Data(contentsOf: url!) {
                
                if let downloadedImage = UIImage(data: data) {
                    
                    DispatchQueue.main.async {
                        withBlock(downloadedImage)
                    }
                    
                }
                
            }
        
        }
    }
}
