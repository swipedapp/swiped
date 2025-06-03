//
//  DatabaseMigrator.swift
//  swiped.
//
//  Created by Adam Demasi on 22/5/2025.
//

import Foundation
import SQLite
import CoreData
import Combine

class DatabaseMigrator {
	
	private let db: Connection?
	private let url = URL.documentsDirectory.appending(path: "swiped.sqlite3")
	
	private let photos = Table("photos")
	
	private let id = SQLite.Expression<String>("id")
	private let type = SQLite.Expression<Int>("type")
	private let size = SQLite.Expression<Double>("size")
	private let choice = SQLite.Expression<Int>("choice")
	private let creationDate = SQLite.Expression<TimeInterval>("creationDate")
	private let swipeDate = SQLite.Expression<TimeInterval>("swipeDate")
	
	init() {
		do {
			if !FileManager.default.fileExists(atPath: url.path) {
				db = nil
				return
			}
			
			db = try Connection(url.path)
			
			try db!.run(photos.create(ifNotExists: true) { t in
				t.column(id, primaryKey: true)
				t.column(type)
				t.column(size)
				t.column(choice)
				t.column(creationDate)
				t.column(swipeDate)
			})
		} catch {
			fatalError(error.localizedDescription)
		}
	}
	
	func needsMigration() async -> Bool {
		await waitForCloudKitSync()

		guard let db = db else {
			return false
		}

		return try! db.scalar(photos.count) > 0
	}

	func waitForCloudKitSync() async {
		await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
			var cancellable: AnyCancellable?
			var timeoutTask: Task<Void, Never>?
			var hasFired = false

			func callback() async {
				try? await Task.sleep(for: .seconds(5))
				if !hasFired {
					hasFired = true
					continuation.resume()
					cancellable?.cancel()
					timeoutTask?.cancel()
				}
			}

			cancellable = NotificationCenter.default.publisher(for: NSPersistentCloudKitContainer.eventChangedNotification)
				.sink { notification in
					timeoutTask?.cancel()
					timeoutTask = Task {
						await callback()
					}
				}

			timeoutTask = Task {
				await callback()
			}
		}
	}

	func migrate(dbController: DatabaseController) async {
		guard let db = db else {
			return
		}

		await waitForCloudKitSync()

		let query = photos.select(*)
		
		for row in try! db.prepare(query) {
			let photo = Photo(id: row[id])
			photo.type = Photo.AssetType(rawValue: row[type]) ?? .unknown
			photo.size = row[size]
			photo.choice = Photo.Choice(rawValue: row[choice])!
			photo.creationDate = Date(timeIntervalSince1970: row[creationDate])
			photo.swipeDate = Date(timeIntervalSince1970: row[swipeDate])
			
			await dbController.addPhoto(photo: photo)
		}
		
		try! FileManager.default.removeItem(at: url)
	}
	
}
