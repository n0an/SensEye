//
//  WebViewController.swift
//  SensEye
//
//  Created by Anton Novoselov on 07/01/2017.
//  Copyright © 2017 Anton Novoselov. All rights reserved.
//

import UIKit
import WebKit

class WebViewController: UIViewController {

    @IBOutlet var containerView: UIView!
    
    var webView: WKWebView!
    
    var urlToLoad: URL?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let url = urlToLoad {
            let request = URLRequest(url: url)
            webView.load(request)
        }
        
//        if let url = URL(string: "http://www.appcoda.com/contact") {
//            let request = URLRequest(url: url)
//            webView.load(request)
//        }
    }
    
    override func loadView() {
        webView = WKWebView()
        view = webView
    }

}
