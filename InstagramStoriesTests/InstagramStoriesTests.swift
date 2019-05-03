//
//  InstagramStoriesTests.swift
//  InstagramStoriesTests
//
//  Created by Ranjith Kumar on 10/23/17.
//  Copyright © 2017 DrawRect. All rights reserved.
//

import XCTest
@testable import InstagramStories

class InstagramStoriesTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testMockFileLoading() {
        do {
            let bundle = Bundle.init(for: type(of: self))
            let stories = try IGMockLoader.loadMockFile(named: "stories.json", bundle: bundle)
            XCTAssertTrue(stories.count > 0)
        } catch let e as MockLoaderError{
            debugPrint(e.description)
            XCTFail()
        }catch{
            XCTFail()
        }
    }
    
}
