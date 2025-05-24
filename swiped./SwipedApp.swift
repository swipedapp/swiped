//
//  SwipedApp.swift
//  swiped.
//
//  Created by tobykohlhagen on 2/5/2025.
//

import SwiftUI
import SwiftData

@main
struct SwipedApp: App {
	var modelContainer: ModelContainer

	@State var needsMigration = false

	private let db: DatabaseController

	init() {
		do {
			let config = ModelConfiguration(url: URL.documentsDirectory.appending(path: "swiped-v2.sqlite3"),
																			cloudKitDatabase: .private("iCloud.com.ma.swipeddata"))
			modelContainer = try ModelContainer(for: Photo.self, configurations: config)
			db = DatabaseController(modelContainer: modelContainer)
		} catch {
			fatalError("Failed to configure SwiftData container.")
		}
	}

	private func migrate() {
		if needsMigration {
			Task {
				try? await Task.sleep(for: .milliseconds(100))
				await self.db.migrate()

				await MainActor.run {
					self.needsMigration = false
				}
			}
		}
	}

	var body: some Scene {
		return WindowGroup {
			NavigationView {
				ContentView()
					.onAppear {
						Task {
							self.needsMigration = await db.needsMigration()
						}
					}
					.sheet(isPresented: $needsMigration, content: {
						MigrationUI()
							.onAppear {
								migrate()
							}
					})
			}
				.toolbar(.hidden)
		}
			.modelContainer(modelContainer)
	}
}

struct ContentView: UIViewControllerRepresentable {
	@Environment(\.modelContext) private var modelContext

	func makeUIViewController(context: Context) -> ViewController {
		let viewController = ViewController()
		viewController.modelContext = modelContext
		return viewController
	}

	func updateUIViewController(_ viewController: ViewController, context: Context) {
		viewController.modelContext = modelContext
	}
}
