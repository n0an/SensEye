//
//  GeneralHelper.swift
//  SensEye
//
//  Created by Anton Novoselov on 30/12/2016.
//  Copyright © 2016 Anton Novoselov. All rights reserved.
//

import UIKit

class GeneralHelper {
    
    private static let _sharedHelper = GeneralHelper()
    
    static var sharedHelper: GeneralHelper {
        return _sharedHelper
    }
    
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
    
}

