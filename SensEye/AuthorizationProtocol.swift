//
//  AuthorizationProtocol.swift
//  SensEye
//
//  Created by Anton Novoselov on 02/04/2018.
//  Copyright © 2018 Anton Novoselov. All rights reserved.
//

import Foundation

protocol AuthorizationProtocol {
    
    func deAuthorize(completed: @escaping (Bool) -> Void)
    
    func authorize(completed: @escaping AuthoizationComplete)
}

extension AuthorizationProtocol {
    func deAuthorize(completed: @escaping (Bool) -> Void) {
        ServerManager.sharedManager.deAuthorize(completed: completed)
    }
    
    func authorize(completed: @escaping AuthoizationComplete) {
        ServerManager.sharedManager.authorize(completed: completed)
    }
}
