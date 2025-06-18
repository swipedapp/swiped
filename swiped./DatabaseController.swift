//
//  DatabaseController.swift
//  swiped.
//
//  Created by tobykohlhagen on 2/5/2025.
//

import Foundation
import Photos
import SwiftData

@ModelActor
actor DatabaseController {

	func needsMigration() async -> Bool {
		let migrator = DatabaseMigrator()
		return await migrator.needsMigration()
	}
	
	func migrate() async {
		let migrator = DatabaseMigrator()
		await migrator.migrate(dbController: self)
		
	}
	
	func reset() {
		let descriptor = FetchDescriptor<Photo>()
		try! modelContext.enumerate(descriptor) { photo in
			modelContext.delete(photo)
		}
		try! modelContext.save()
	}
	
	func addPhoto(photo: Photo) {
		if let photo2 = getPhoto(id: photo.id) {
			modelContext.delete(photo2)
		}
		
		modelContext.insert(photo)
		try! modelContext.save()
	}
	
	func getPhoto(id photoID: String) -> Photo? {
		let descriptor = FetchDescriptor<Photo>(predicate: #Predicate {
			$0.id == photoID
		})
		return try! modelContext.fetch(descriptor).first
	}
	
	func getTotal() -> Int {
		let descriptor = FetchDescriptor<Photo>()
		return try! modelContext.fetchCount(descriptor)
	}
	
	func getTotalKept() -> Int {
		let keep = Photo.Choice.keep.rawValue
		let descriptor = FetchDescriptor<Photo>(predicate: #Predicate {
			$0._choice == keep
		})
		return try! modelContext.fetchCount(descriptor)
	}
	
	func getTotalDeleted() -> Int {
		let delete = Photo.Choice.delete.rawValue
		let descriptor = FetchDescriptor<Photo>(predicate: #Predicate {
			$0._choice == delete
		})
		return try! modelContext.fetchCount(descriptor)
	}
	
	func getTotalPhotoDeleted() -> Int {
		let delete = Photo.Choice.delete.rawValue
		let image = Photo.AssetType.image.rawValue
		let descriptor = FetchDescriptor<Photo>(predicate: #Predicate {
			$0._choice == delete && $0._type == image
		})
		return try! modelContext.fetchCount(descriptor)
	}
	func getTotalVideoDeleted() -> Int {
		let delete = Photo.Choice.delete.rawValue
		let video = Photo.AssetType.video.rawValue
		let descriptor = FetchDescriptor<Photo>(predicate: #Predicate {
			$0._choice == delete && $0._type == video
		})
		return try! modelContext.fetchCount(descriptor)
	}
	
	func getSpaceSaved() -> Double {
		let delete = Photo.Choice.delete.rawValue
		let descriptor = FetchDescriptor<Photo>(predicate: #Predicate {
			$0._choice == delete
		})
		var size = 0.0
		try! modelContext.enumerate(descriptor) { photo in
			size += photo.size
		}
		return size
	}
	func calcSwipeScore() -> Int64 {
		let totalKept = getTotalKept()
		let totalDL = getTotalDeleted() * 2
		let totalVideo = getTotalVideoDeleted() * 2
		let totalIMG = getTotalPhotoDeleted()
		let totalSpaceMB = Int64(getSpaceSaved()) / 1024 / 1024
		return Int64(totalIMG + totalDL + totalKept + totalVideo) + totalSpaceMB
	}
}
