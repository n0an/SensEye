//
//  VKLoginViewController.swift
//  SensEye
//
//  Created by Anton Novoselov on 06/01/2017.
//  Copyright © 2017 Anton Novoselov. All rights reserved.
//

import UIKit

typealias CompletionHandler = (VKAccessToken?) -> Void

class VKLoginViewController: UIViewController {
    
    
    @IBOutlet weak var webView: UIWebView!
    var completionHandler: CompletionHandler?

    override func viewDidLoad() {
        super.viewDidLoad()

//        var rect = self.view.bounds
//        
//        rect.origin = CGPoint.zero
//        
//        let webView = UIWebView(frame: rect)
//        webView.delegate = self
//        
//        self.view.addSubview(webView)
        
//        self.webView = webView
        
//        let cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(actionCancelTapped))
//        
//        self.navigationItem.setRightBarButton(cancelButton, animated: false)
//        
//        self.navigationItem.title = "Login"
        
        
        let urlString = "https://oauth.vk.com/authorize?" +
                        "client_id=5795076&" +
                        "scope=405526&" +
                        "redirect_uri=https://oauth.vk.com/blank.html&" +
                        "display=mobile&" +
                        "response_type=token"

        let url = URL(string: urlString)
        
        let request = URLRequest(url: url!)
        
        webView.delegate = self
        
        webView.loadRequest(request)
        
        
    }
    
    deinit {
        self.webView.delegate = nil
    }

    
    @IBAction func actionCancelTapped() {
        
        if let completionHandler = self.completionHandler {
            completionHandler(nil)
        }
        
        self.dismiss(animated: true, completion: nil)
    }
    
    
    

}





extension VKLoginViewController: UIWebViewDelegate {
    
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        
        if let range = request.url?.description.range(of: "#access_token=") {
            
            print("range.lowerBound = \(range.lowerBound)")
            print("range.upperBound = \(range.upperBound)")
            
            let accessToken = VKAccessToken()
            
            var query = request.url?.description
            
            let array = query!.components(separatedBy: "#")
            
            if (array.count) > 1 {
                query = array.last
            }
            
            let pairsArray = query!.components(separatedBy: "&")
            
            for pair in pairsArray {
                
                let values = pair.components(separatedBy: "=")
                
                if values.count == 2 {
                    
                    let key = (values.first)!
                    
                    if key == "access_token" {
                        accessToken.token = values.last!
                        
                    } else if key == "expires_in" {
                        
                        let timeStamp = Double(values.last!)
                        
                        let interval = TimeInterval(timeStamp!)
                        
                        accessToken.expirationDate = Date(timeIntervalSinceNow: interval)
                        
                    } else if key == "user_id" {
                        
                        accessToken.userID = values.last!
                        
                    }
                    
                }
                
            }
            
            self.webView.delegate = nil
            
            if let completionHandler = completionHandler {
                completionHandler(accessToken)
                
                // Post notification when authenticated with VK
                
                let center = NotificationCenter.default
                let notification = Notification(name: Notification.Name(rawValue: "NotificationAuthorizationCompleted"))
                
                center.post(notification)
                
            }
            
            self.dismiss(animated: true, completion: nil)
            
            return false
            
        }
        
  
        
        return true
        
    }
    
    
}









































