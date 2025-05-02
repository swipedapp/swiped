//
//  DatabaseController.swift
//  swiped.
//
//  Created by tobykohlhagen on 2/5/2025.
//

import Foundation
import SQLite

class DatabaseController {

	static let shared = DatabaseController()

	private let db: Connection

	private let photos = Table("photos")
	
	private let id = SQLite.Expression<String>("id")
	private let size = SQLite.Expression<Double>("size")
	private let choice = SQLite.Expression<Int>("choice")
	private let swipeDate = SQLite.Expression<TimeInterval>("swipeDate")

	private init() {
		do {
			let documents = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
			let path = documents.appendingPathComponent("swiped.sqlite3")
			db = try Connection(path.path)
			
			try db.run(photos.create(ifNotExists: true) { t in
				t.column(id, primaryKey: true)
				t.column(size)
				t.column(choice)
				t.column(swipeDate)
			})
		} catch {
			fatalError(error.localizedDescription)
		}
	}
	
	func addPhoto(photo: Photo) {
		try! db.run(photos.insert(
			or: .replace,
			id <- photo.id,
			size <- photo.size,
			choice <- photo.choice.rawValue,
			swipeDate <- photo.swipeDate?.timeIntervalSince1970 ?? 0
		))
	}
	
	func getPhoto(id photoID: String) -> Photo? {
		let query = photos.select(*)
			.where(id == photoID)
			.limit(1)

		guard let row = try! db.pluck(query) else {
			return nil
		}
		
		let photo = Photo(id: row[id])
		photo.size = row[size]
		photo.choice = Photo.Choice(rawValue: row[choice])!
		photo.swipeDate = Date(timeIntervalSince1970: row[swipeDate])
		return photo
	}
	
}
