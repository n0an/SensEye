//
//  Search.swift
//  SensEye
//
//  Created by Anton Novoselov on 02/01/2017.
//  Copyright © 2017 Anton Novoselov. All rights reserved.
//

import UIKit

typealias SearchComplete = (Bool) -> Void

class Search {
    
    enum State {
        case NotSearchedYet
        case Loading
        case NoResults
        case Results
    }
    
    // MARK: - PROPERTIES
    
    private(set) var state: State = .NotSearchedYet
    
    
    private var dataTask: URLSessionDataTask? = nil

    
}
