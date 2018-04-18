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
        
        authorize { (user) in
            
            self.setVKUser(user: user)
            
            if !self.checkIfCurrentVKUserExists() {
                XCTFail("Authorize using app run")
            }
            
            self.getLastPost(completion: { (post) in
                
                guard let post = post else {
                    XCTFail("Can not fetch post")
                    return
                }
                
                self.createComment(ownerID: groupID, postID: post.postID, message: "test comment", completed: { (success) in
                    
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
    
    func testAddLikeToPost() {
        let likeAddExpectation = expectation(description: "likeAddExpectation")
        
        authorize { (user) in
            
            self.setVKUser(user: user)
            
            if !self.checkIfCurrentVKUserExists() {
                XCTFail("Authorize using app run")
            }
            
            self.getLastPost(completion: { (post) in
                
                guard let post = post else {
                    XCTFail("Can not fetch post")
                    return
                }
                
                self.addLike(forItemType: .post, ownerID: groupID, itemID: post.postID, completed: { (success, resultDict) in
                    if success {
                        likeAddExpectation.fulfill()
                    } else {
                        XCTFail("can't add like")
                    }
                })
                
                
            })
        }
        
        waitForExpectations(timeout: 10) { (err) in
            XCTAssertNil(err, "likeAddExpectation timeout")
        }
    }
    
    func testDeleteLikeFromPost() {
        let likeDeleteExpectation = expectation(description: "likeDeleteExpectation")
        
        authorize { (user) in
            
            self.setVKUser(user: user)
            
            if !self.checkIfCurrentVKUserExists() {
                XCTFail("Authorize using app run")
            }
            
            
            self.getLastPost(completion: { (post) in
                
                guard let post = post else {
                    XCTFail("Can not fetch post")
                    return
                }
                
                self.isLiked(forItemType: .post, ownerID: groupID, itemID: post.postID, completed: { (resultDict) in
                    
                    if let resultDict = resultDict,
                        let liked = resultDict["liked"] as? Int {
                        
                        if liked == 1 {
                            
                            self.deleteLike(forItemType: .post, ownerID: groupID, itemID: post.postID, completed: { (success, resultDict) in
                                if success {
                                    likeDeleteExpectation.fulfill()
                                } else {
                                    XCTFail("can't delete like")
                                }
                            })
                            
                            
                            
                        } else {
                            // Not liked. Add like first
                            self.addAndDeleteLike(forItemType: .post, itemID: post.postID, completion: { (success) in
                                if success {
                                    likeDeleteExpectation.fulfill()
                                } else {
                                    XCTFail("can't delete like")
                                }
                            })
                            
                        }
                        
                        
                    } else {
                        // Not liked. Add like first
                        self.addAndDeleteLike(forItemType: .post, itemID: post.postID, completion: { (success) in
                            if success {
                                likeDeleteExpectation.fulfill()
                            } else {
                                XCTFail("can't delete like")
                            }
                        })
                    }
                    
                })
            })
        }
        
        waitForExpectations(timeout: 10) { (err) in
            XCTAssertNil(err, "likeDeleteExpectation timeout")
        }
    }
    
    
    func testAuthorize() {
        
        let authorizeExpectation = expectation(description: "authorizeExpectation")
        
        authorize { (user) in
            
            self.setVKUser(user: user)
            
            if !self.checkIfCurrentVKUserExists() {
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
        
        getFeed(forType: .post, ownerID: groupID, offset: 0, count: 1) { (posts) in
            
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
  
    func addAndDeleteLike(forItemType itemType: FeedItemsType, itemID: String, completion: @escaping (Bool)->()) {
        self.addLike(forItemType: itemType, ownerID: groupID, itemID: itemID, completed: { (success, resultDict) in
            if success {
                
                self.deleteLike(forItemType: itemType, ownerID: groupID, itemID: itemID, completed: { (success, resultDict) in
                    
                    if success {
                        completion(true)
                    } else {
                        completion(false)
                    }
                })
                
            } else {
                completion(false)
            }
        })
    }
    
}

extension SensEyeTests: ProjectProtocol  { }
