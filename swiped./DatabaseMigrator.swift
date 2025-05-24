//
//  DatabaseMigrator.swift
//  swiped.
//
//  Created by Adam Demasi on 22/5/2025.
//

import Foundation
import SQLite

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

	func needsMigration() -> Bool {
		guard let db = db else {
			return false
		}

		return try! db.scalar(photos.count) > 0
	}

	func migrate(dbController: DatabaseController) async {
		guard let db = db else {
			return
		}

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
