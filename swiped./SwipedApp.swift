//
//  SwipedApp.swift
//  swiped.
//
//  Created by tobykohlhagen on 2/5/2025.
//

import SwiftUI
import Sentry

import SwiftData
import OSLog

@main
struct SwipedApp: App {
	private var modelContainer: ModelContainer
	private let logger = Logger(subsystem: "Init", category: "SwiftData")

	@State private var needsMigration = false

	private let cardInfo = CardInfo()
	// add the sheet manager
	private let sheetManager = SheetManager()

	private let db: DatabaseController
	
	init() {
#if !DEBUG
		SentrySDK.start { options in
			options.dsn = "https://9faa97646e6bfe1acc924b41b4f4c63a@o4509432764760064.ingest.de.sentry.io/4509432769216592"
			options.debug = false // Enabled debug when first installing is always helpful
			
			// Adds IP for users.
			// For more information, visit: https://docs.sentry.io/platforms/apple/data-management/data-collected/
			options.sendDefaultPii = true
			
			// Set tracesSampleRate to 1.0 to capture 100% of transactions for performance monitoring.
			// We recommend adjusting this value in production.
			options.tracesSampleRate = 1.0
			options.sessionReplay.onErrorSampleRate = 1.0
			options.sessionReplay.sessionSampleRate = 1.0
			options.sessionReplay.maskAllText = false
			options.sessionReplay.maskAllImages = true
			// Configure profiling. Visit https://docs.sentry.io/platforms/apple/profiling/ to learn more.
			options.configureProfiling = {
				$0.sessionSampleRate = 1.0 // We recommend adjusting this value in production.
				$0.lifecycle = .trace
			}
			
			// Uncomment the following lines to add more data to your events
			// options.attachScreenshot = true // This adds a screenshot to the error events
			// options.attachViewHierarchy = true // This adds the view hierarchy to the error events
		}
#endif

		do {
			let config = ModelConfiguration(url: URL.documentsDirectory.appending(path: "swiped-v2.sqlite3"),
																			cloudKitDatabase: .private("iCloud.com.ma.swipeddata"))
			modelContainer = try ModelContainer(for: Photo.self, configurations: config)
			db = DatabaseController(modelContainer: modelContainer)
		} catch {
			logger.critical("Failed to configure SwiftData container.")
			SentrySDK.capture(error: error)
			fatalError(error.localizedDescription)
		}
	}
	
	private func migrate() {
		if needsMigration {
			logger.info("Starting migration..")
			Task {
				try? await Task.sleep(for: .milliseconds(100))
				await db.migrate()
				needsMigration = false
			}
		}
	}
	
	var body: some Scene {
		return WindowGroup {
			NavigationView {
				MainView()
					.onAppear {
						Task {
							needsMigration = await db.needsMigration()
						}
					}
					.sheet(isPresented: $needsMigration, content: {
						MigrationUI()
							.onAppear {
								migrate()
							}
					})
			}
				.navigationViewStyle(.stack)
		}
			.environmentObject(cardInfo)
			.environmentObject(sheetManager)
			.modelContainer(modelContainer)
	}
}
