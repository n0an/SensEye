//
//  ServerObject.swift
//  SensEye
//
//  Created by Anton Novoselov on 04/01/2017.
//  Copyright © 2017 Anton Novoselov. All rights reserved.
//

import Foundation
import SwiftyJSON

protocol ServerObject {
    
    // MARK: - PROPERTIES
    var postAuthorID: String! { get set }
    var postAuthor: User? { get set }
    var postGroupAuthor: Group? { get set }
    
    // MARK: - INITIALIZERS
    init(responseObject: JSON)
}
