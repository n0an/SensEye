//
//  RecetPasswordViewController.swift
//  SensEye
//
//  Created by Anton Novoselov on 16/01/2017.
//  Copyright © 2017 Anton Novoselov. All rights reserved.
//

import UIKit

class RecetPasswordViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.isNavigationBarHidden = false
    }

    deinit {
        print("===NAG=== RecetPasswordViewController deinit")
    }
    
    @IBAction func actionResetPasswordButtonTapped(_ sender: Any) {
    }

}
