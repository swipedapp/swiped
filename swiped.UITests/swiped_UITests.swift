//
//  swiped_UITests.swift
//  swiped.UITests
//
//  Created by tobykohlhagen on 23/5/2025.
//

import XCTest

final class swiped_UITests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

	override func tearDownWithError() throws {
		// Put teardown code here. This method is called after the invocation of each test method in the class.
	}
	
	@MainActor
	func testStuff() throws {
		
	}
    

    @MainActor
			func testExample() throws {
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        app.launch()

        // Use XCTAssert and related functions to verify your tests produce the correct results.
			
			app.activate()
			let keepStaticText = app/*@START_MENU_TOKEN@*/.staticTexts["Keep"]/*[[".buttons[\"Keep\"].staticTexts.firstMatch",".buttons.staticTexts[\"Keep\"]",".staticTexts[\"Keep\"]"],[[[-1,2],[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
			keepStaticText.tap()
			
			let deleteStaticText = app/*@START_MENU_TOKEN@*/.staticTexts["Delete"]/*[[".buttons[\"Delete\"].staticTexts.firstMatch",".buttons.staticTexts[\"Delete\"]",".staticTexts[\"Delete\"]"],[[[-1,2],[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
			deleteStaticText.tap()
			keepStaticText.tap()
			deleteStaticText.tap()
			keepStaticText.tap()
			deleteStaticText.tap()
			deleteStaticText.tap()
			keepStaticText.tap()
			deleteStaticText.tap()
			keepStaticText.tap()
			deleteStaticText.tap()
			keepStaticText.tap()
			deleteStaticText.tap()
			keepStaticText.tap()
			deleteStaticText.tap()
			keepStaticText.tap()
			deleteStaticText.tap()
			keepStaticText.tap()
			deleteStaticText.tap()
			keepStaticText.tap()
			deleteStaticText.tap()
			keepStaticText.tap()
			deleteStaticText.tap()
			
			XCUIDevice.shared.press(.home)
			
			let springboardApp = XCUIApplication(bundleIdentifier: "com.apple.springboard")
			springboardApp/*@START_MENU_TOKEN@*/.buttons["Delete"]/*[[".otherElements.buttons[\"Delete\"]",".buttons[\"Delete\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
			
    }
	
	

    @MainActor
    func testLaunchPerformance() throws {
        // This measures how long it takes to launch your application.
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }
}
