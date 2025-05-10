//
//  DatabaseController.swift
//  swiped.
//
//  Created by tobykohlhagen on 2/5/2025.
//

import Foundation
import SQLite
import Photos

class DatabaseController {
	
	static let shared = DatabaseController()
	
	private let db: Connection
	
	private let photos = Table("photos")
	
	private let id = SQLite.Expression<String>("id")
	private let type = SQLite.Expression<Int>("type")
	private let size = SQLite.Expression<Double>("size")
	private let choice = SQLite.Expression<Int>("choice")
	private let creationDate = SQLite.Expression<TimeInterval>("creationDate")
	private let swipeDate = SQLite.Expression<TimeInterval>("swipeDate")
	
	private init() {
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
	
	func addPhoto(photo: Photo) {
		try! db.run(photos.insert(
			or: .replace,
			id <- photo.id,
			type <- photo.type.rawValue,
			size <- photo.size,
			choice <- photo.choice.rawValue,
			creationDate <- photo.creationDate?.timeIntervalSince1970 ?? 0,
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
		photo.type = PHAssetMediaType(rawValue: row[type]) ?? .unknown
		photo.size = row[size]
		photo.choice = Photo.Choice(rawValue: row[choice])!
		photo.creationDate = Date(timeIntervalSince1970: row[creationDate])
		photo.swipeDate = Date(timeIntervalSince1970: row[swipeDate])
		return photo
	}
	
	func getTotalKept() -> Int {
		return try! db.scalar(photos
			.filter(choice == Photo.Choice.keep.rawValue)
			.count)
	}
	
	func getTotalDeleted() -> Int {
		return try! db.scalar(photos
			.filter(choice == Photo.Choice.delete.rawValue)
			.count)
	}
	func getTotalPhotoDeleted() -> Int {
		return try! db.scalar(photos
			.filter(choice == Photo.Choice.delete.rawValue)
			.filter(type == PHAssetMediaType.image.rawValue)
			.count)
	}
	func getTotalVideoDeleted() -> Int {
		return try! db.scalar(photos
			.filter(choice == Photo.Choice.delete.rawValue)
			.filter(type == PHAssetMediaType.video.rawValue)
			.count)
	}
	
	func getSpaceSaved() -> Double {
		return try! db.scalar(photos
			.select(size.total)
			.filter(choice == Photo.Choice.delete.rawValue))
	}
	func calcSwipeScore() -> Int {
		let totalKept = getTotalKept()
		let totalDL = getTotalDeleted() * 2
		let totalVideo = getTotalVideoDeleted() * 2
		let totalIMG = getTotalPhotoDeleted()
		let totalSpaceMB = Int(getSpaceSaved()) / 1024 / 1024
		return totalIMG + totalDL + totalKept + totalVideo + totalSpaceMB
	}
}
