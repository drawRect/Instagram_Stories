//
//  IGAutomaticFlowTests.swift
//  InstagramStoriesTests
//
//  Created by Sonata on 13/03/19.
//  Copyright © 2019 Dash. All rights reserved.
//

import XCTest

class IGAutomaticFlowTests: IGUITest {
    func testNormalFlow() {
        app.staticTexts["Terasa"].tap()
        let scrollView = app.collectionViews.element.cells.element.scrollViews.element
        scrollView.tap()
        scrollView.tap()
        XCTAssert(app.staticTexts["6h"].exists)
    }
}
