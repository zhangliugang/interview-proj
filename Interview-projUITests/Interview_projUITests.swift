//
//  Interview_projUITests.swift
//  Interview-projUITests
//
//  Created by August on 11/17/20.
//

import XCTest

class Interview_projUITests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

		let app = XCUIApplication()
		setupSnapshot(app)
		app.launch()
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // UI tests must launch the application that they test.
		let app = XCUIApplication()
		
		snapshot("endpoint_list_view")
		
		let history_btn = app.navigationBars["Github"].buttons["History"]
		XCTAssert(history_btn.exists)
		XCTAssert(app.staticTexts["Github"].exists)
		history_btn.tap()
		
		snapshot("history_view")
		
		let done_btn = app.navigationBars["History"].buttons["Done"]
		XCTAssert(done_btn.exists)
		XCTAssert(app.staticTexts["History"].exists)
		done_btn.tap()
						
    }

//    func testLaunchPerformance() throws {
//        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, *) {
//            // This measures how long it takes to launch your application.
//            measure(metrics: [XCTApplicationLaunchMetric()]) {
//                XCUIApplication().launch()
//            }
//        }
//    }
}
