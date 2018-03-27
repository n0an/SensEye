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
    
    
    
    func testPerformanceExample() {
      
//        let fetchExpectation = expectation(description: "some")
        
        self.measure {
            
            

            ServerManager.sharedManager.getFeed(forType: .post, ownerID: groupID, offset: 0, count: 10, completed: { (posts) in
//                fetchExpectation.fulfill()

            })


            
        }
        
//        waitForExpectations(timeout: 5) { (err) in
//            XCTAssertNil(err, "some failed")
//        }
    }
    
}
