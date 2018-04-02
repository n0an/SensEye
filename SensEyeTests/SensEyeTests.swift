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
        
        getLastPost { (post) in
            guard post != nil else {
                XCTFail("Can not fetch post")
                return
            }
            postFetchExpectation.fulfill()
        }
     
        waitForExpectations(timeout: 5) { (err) in
            XCTAssertNil(err, "postFetchTimeout")
        }
    }
    
    
    func testAddComment() {
        let commentAddExpectation = expectation(description: "commentAddExpectation")
        
        ServerManager.sharedManager.authorize { (user) in
            ServerManager.sharedManager.currentVKUser = user
            
            if ServerManager.sharedManager.currentVKUser == nil {
                XCTFail("Authorize using app run")
            }
            
            self.getLastPost(completion: { (post) in
                
                guard let post = post else {
                    XCTFail("Can not fetch post")
                    return
                }
                
                ServerManager.sharedManager.createComment(ownerID: groupID, postID: post.postID, message: "test comment", completed: { (success) in
                    
                    print(success)
                    
                    if success {
                        commentAddExpectation.fulfill()
                    } else {
                        XCTFail("can't add comment")
                    }
                })
            })
        }
        
        waitForExpectations(timeout: 10) { (err) in
            XCTAssertNil(err, "commentAddExpectation timeout")
        }
    }
    
    func testAuthorize() {
        
        let authorizeExpectation = expectation(description: "authorizeExpectation")
        
        ServerManager.sharedManager.authorize { (user) in
            ServerManager.sharedManager.currentVKUser = user
            
            if ServerManager.sharedManager.currentVKUser == nil {
                XCTFail("Authorize using app run")
            }
            
            authorizeExpectation.fulfill()
            
        }
        
        waitForExpectations(timeout: 5) { (err) in
            XCTAssertNil(err, "authorizeExpectation timeout")
        }
    }
    
    // MARK: - HELPER METHODS
    func getLastPost(completion: @escaping (WallPost?) -> ()) {
        ServerManager.sharedManager.getFeed(forType: .post, ownerID: groupID, offset: 0, count: 1) { (posts) in
            
            if let posts = posts as? [WallPost] {
                if !posts.isEmpty {
                    completion(posts[0])
                } else {
                    completion(nil)
                }
            } else {
                completion(nil)
            }
        }
    }
    
}
