//
//  ServerObject.swift
//  SensEye
//
//  Created by Anton Novoselov on 04/01/2017.
//  Copyright © 2017 Anton Novoselov. All rights reserved.
//

import Foundation

protocol ServerObject {
    
    var postAuthorID: String! { get set }
    var postAuthor: User? { get set }
    var postGroupAuthor: Group? { get set }
    
    init(responseObject: [String: Any])
    
}
