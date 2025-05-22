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

	init() {
		do {
			let config = ModelConfiguration(url: URL.documentsDirectory.appending(path: "swiped.sqlite3"),
																			cloudKitDatabase: .none)
			modelContainer = try ModelContainer(for: Photo.self, configurations: config)
		} catch {
			fatalError("Failed to configure SwiftData container.")
		}
	}

	var body: some Scene {
		WindowGroup {
			ContentView()
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
