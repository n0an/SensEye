//
//  SensEyeTests.swift
//  SensEyeTests
//
//  Created by Anton Novoselov on 27/03/2018.
//  Copyright © 2018 Anton Novoselov. All rights reserved.
//

import XCTest

@testable import SensEye

class SensEyeTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testFetchPost() {
        
        let postFetchExpectation = expectation(description: "postFetchExpectation")
        
        ServerManager.sharedManager.getFeed(forType: .post, ownerID: groupID, offset: 0, count: 1) { (posts) in
            
            if let posts = posts as? [WallPost] {
                if !posts.isEmpty {
                    postFetchExpectation.fulfill()
                }
            }
        }
        
        waitForExpectations(timeout: 5) { (err) in
            XCTAssertNil(err, "postFetchTimeout")
        }
    }
    
}
