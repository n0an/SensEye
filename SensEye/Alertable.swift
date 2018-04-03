//
//  Alertable.swift
//  SensEye
//
//  Created by Anton Novoselov on 03/04/2018.
//  Copyright © 2018 Anton Novoselov. All rights reserved.
//

import UIKit

protocol Alertable {
    func showAlert(_ msg: String)
}

extension Alertable where Self: UIViewController {
    func showAlert(_ msg: String) {
        let alertController = UIAlertController(title: "Error:", message: msg, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(action)
        present(alertController, animated: true, completion: nil)
    }
    
    func alert(title: String?, message: String?, handler: ((UIAlertAction) -> Void)? = nil) {
        let alert = UIAlertController.alert(title: title, message: message, handler: handler)
        present(alert, animated: true, completion: nil)
    }
    
    func alertError(error: NSError, handler: ((UIAlertAction) -> Void)? = nil) {
        let alert = UIAlertController.alertError(error: error, handler: handler)
        present(alert, animated: true, completion: nil)
    }
    
    func confirm(title: String?, message: String?, handler: @escaping (UIAlertAction) -> Void) {
        let alert = UIAlertController.confirm(title: title, message: message, handler: handler)
        present(alert, animated: true, completion: nil)
    }
}

// MARK: - UIAlertController Extension
extension UIAlertController {
    public static func alert(title: String?, message: String?, handler: ((UIAlertAction) -> Void)? = nil) -> UIAlertController {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: handler))
        return alert
    }
    
    public static func alertError(error: NSError, handler: ((UIAlertAction) -> Void)? = nil) -> UIAlertController {
        return UIAlertController.alert(title: error.localizedDescription, message: error.localizedRecoverySuggestion, handler: handler)
    }
    
    public static func confirm(title: String?, message: String?, handler: @escaping (UIAlertAction) -> Void) -> UIAlertController {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("No", comment: "No"), style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: NSLocalizedString("Yes", comment: "Yes"), style: .default, handler: handler))
        return alert
    }
}
