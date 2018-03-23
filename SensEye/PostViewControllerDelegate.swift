//
//  PostViewControllerDelegate.swift
//  SensEye
//
//  Created by Anton Novoselov on 23/03/2018.
//  Copyright © 2018 Anton Novoselov. All rights reserved.
//

import Foundation

// MARK: - DELEGATE
protocol PostViewControllerDelegate: AnyObject {
    func postViewControllerWillDisappear(withPost post: WallPost)
}
