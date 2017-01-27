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
    
    private static let _sharedHelper = GeneralHelper()
    
    static var sharedHelper: GeneralHelper {
        return _sharedHelper
    }
    
    public enum DGSpinnerPosition {
        case left
        case right
        case center
        case top
        case bottom
    }
    
    public var kONESIGNALAPPID = ""
    public var appOwnerUID = ""
    
    
    public func showAlertOnViewController(viewController: UIViewController, withTitle title: String, message: String, buttonTitle: String) {
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: buttonTitle, style: .default, handler: nil)
        alertVC.addAction(action)
        viewController.present(alertVC, animated: true, completion: nil)
    }
    
    
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
        
        let dgSpinner = view.viewWithTag(1001) as! DGActivityIndicatorView
        dgSpinner.stopAnimating()
        
        view.viewWithTag(1001)?.removeFromSuperview()
    }
    
    
    
    public func showVKAuthorizeActionSheetOnViewController(viewController: UIViewController, completion: @escaping (Bool) -> Void) {
        
        let actionSheet = UIAlertController(title: "Необходима авторизация", message: "Для доступа к функционалу лайков и комментариев, необходимо авторизоваться в Вконтакте. Действие нужно выполнить один раз", preferredStyle: .actionSheet)
        
        let okAction = UIAlertAction(title: "OK", style: .default) { (action) in
            
            completion(true)
        }
        
        let cancelAction = UIAlertAction(title: "Отмена", style: .cancel) { (action) in
            completion(false)
        }
        
        actionSheet.addAction(okAction)
        actionSheet.addAction(cancelAction)
        
        viewController.present(actionSheet, animated: true, completion: nil)
        
    }
    
    public func showLogoutView(onViewController viewController: UIViewController, withHandler handler: @escaping (_ success: Bool) -> Void) {
        
        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let logOut = UIAlertAction(title: "Log Out", style: .destructive) { (alert: UIAlertAction!) in
            
            handler(true)
            
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (alert: UIAlertAction!) in
            
        }
        
        optionMenu.addAction(logOut)
        optionMenu.addAction(cancelAction)
        
        viewController.present(optionMenu, animated: true, completion: nil)
        
    }
    
    
    
    public func downloadImage(withURL urlPhoto: URL, onComplete: @escaping (UIImage?) -> Void) {
        
        let session = URLSession.shared
        
        let downloadTask = session.downloadTask(with: urlPhoto) { (localFile, response, error) -> Void in
            
            if error == nil && localFile != nil {
                
                if let data = try? Data(contentsOf: urlPhoto) {
                    
                    if let downloadedImage = UIImage(data: data) {
                        
                        onComplete(downloadedImage)
                        
                    }
                }
            }
        }
        
        downloadTask.resume()
        
        
    }
    

    
}

























