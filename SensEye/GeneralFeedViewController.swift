//
//  GeneralFeedViewController.swift
//  SensEye
//
//  Created by Anton Novoselov on 02/04/2018.
//  Copyright © 2018 Anton Novoselov. All rights reserved.
//

import UIKit

class GeneralFeedViewController: UIViewController {

    
    // MARK: - HELPER METHODS
    func toAuthorize() {
        authorize { (user) in
            
            self.setVKUser(user: user)
        }
    }


}

extension GeneralFeedViewController: FeedProtocol, AuthorizationProtocol, LikesProtocol, PhotosProtocol { }
