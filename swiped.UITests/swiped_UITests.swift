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
		app.resetAuthorizationStatus(for: .photos)
		app.launch()
		app.activate()

		let springboardApp = XCUIApplication(bundleIdentifier: "com.apple.springboard")
		springboardApp.buttons["Allow Full Access"].tap()

		takeScreenshot(of: app, named: "Launch")

		let keepStaticText = app.staticTexts["Keep"]
		keepStaticText.tap()
		let deleteStaticText = app.staticTexts["Delete"]
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
		keepStaticText.tap()
		deleteStaticText.tap()
		if springboardApp.buttons["Delete"].waitForExistence(timeout: 5) {
			springboardApp.buttons["Delete"].tap()
		}
		

		takeScreenshot(of: app, named: "Summary")
		let elementsQuery = app.otherElements
		let element = elementsQuery/*@START_MENU_TOKEN@*/.containing(.staticText, identifier: "SWIPE DOWN TO DISMISS").firstMatch/*[[".element(boundBy: 40)",".containing(.staticText, identifier: \"VERSION 1.1.1 (1)\").firstMatch",".containing(.staticText, identifier: \"SWIPED.\").firstMatch",".containing(.staticText, identifier: \"SWIPE DOWN TO DISMISS\").firstMatch"],[[[-1,3],[-1,2],[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
		element.tap()
		takeScreenshot(of: app, named: "Settings")
		element.swipeDown()

		app.terminate()

		let icon = springboardApp.icons["swiped."]
		if icon.exists {
			icon.press(forDuration: 1)

			let buttonRemoveApp = springboardApp.buttons["Remove App"]
			if buttonRemoveApp.waitForExistence(timeout: 5) {
				buttonRemoveApp.tap()
			}

			let buttonDeleteApp = springboardApp.alerts.buttons["Delete App"]
			if buttonDeleteApp.waitForExistence(timeout: 5) {
				buttonDeleteApp.tap()
			}

			let buttonDelete = springboardApp.alerts.buttons["Delete"]
			if buttonDelete.waitForExistence(timeout: 5) {
				buttonDelete.tap()
			}
		}
	}
	
	

    @MainActor
    func testLaunchPerformance() throws {
        // This measures how long it takes to launch your application.
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }
}
