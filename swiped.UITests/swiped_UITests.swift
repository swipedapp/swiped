//
//  swiped_UITests.swift
//  swiped.UITests
//
//  Created by tobykohlhagen on 23/5/2025.
//

import XCTest
extension XCTestCase {
	/// Take a screenshot of a given app and add it to the test attachements.
	/// - Parameters:
	///   - app: The app to take a screenshot of.
	///   - name: The name of the screenshot.
	func takeScreenshot(of app: XCUIApplication, named name: String) {
		let screenshot = app.windows.firstMatch.screenshot()
		let attachment = XCTAttachment(screenshot: screenshot)
#if os(iOS)
		attachment.name = "Screenshot-\(name)-\(UIDevice.current.name).png"
#else
		attachment.name = "Screenshot-\(name)-macOS.png"
#endif
		attachment.lifetime = .keepAlways
		add(attachment)
	}
}
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
		let app = XCUIApplication()
		app.launch()
		
		takeScreenshot(of: app, named: "Launch")
	}
	
	

    @MainActor
    func testLaunchPerformance() throws {
        // This measures how long it takes to launch your application.
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }
}
