//
//  DatabaseMigrator.swift
//  swiped.
//
//  Created by Adam Demasi on 22/5/2025.
//

import Foundation
import SQLite

class DatabaseMigrator {

	private let db: Connection

	private let photos = Table("photos")

	private let id = SQLite.Expression<String>("id")
	private let type = SQLite.Expression<Int>("type")
	private let size = SQLite.Expression<Double>("size")
	private let choice = SQLite.Expression<Int>("choice")
	private let creationDate = SQLite.Expression<TimeInterval>("creationDate")
	private let swipeDate = SQLite.Expression<TimeInterval>("swipeDate")

	init() {
		do {
			let documents = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
			let path = documents.appendingPathComponent("swiped.sqlite3")
			db = try Connection(path.path)

			try db.run(photos.create(ifNotExists: true) { t in
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
		return try! db.scalar(photos.count) > 0
	}

	func migrate(dbController: DatabaseController) {
		let query = photos.select(*)

		for row in try! db.prepare(query) {
			let photo = Photo(id: row[id])
			photo.type = Photo.AssetType(rawValue: row[type]) ?? .unknown
			photo.size = row[size]
			photo.choice = Photo.Choice(rawValue: row[choice])!
			photo.creationDate = Date(timeIntervalSince1970: row[creationDate])
			photo.swipeDate = Date(timeIntervalSince1970: row[swipeDate])

			dbController.addPhoto(photo: photo)
		}

		try! db.run(photos.delete())
	}

}
