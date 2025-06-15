//
//  PhotosController.swift
//  swiped.
//
//  Created by tobykohlhagen on 2/5/2025.
//

import UIKit
import Photos
import CoreTransferable
import os
import Sentry

class PhotosController {
	
	protocol PhotoLoadDelegate: AnyObject {
		func didLoadThumbnail(for card: PhotoCard, image: UIImage)
		func didLoadFullImage(for card: PhotoCard, image: UIImage)
		func didFail(error: PhotoError)
	}
	
	enum PhotoError: Error {
		case noAccessToPhotoLibrary
		case noPhotosAvailable
		case noPhotosLeft
		case failedToFetchPhoto
		case failedToDelete
	}
	
	weak var delegate: PhotoLoadDelegate?
	
	var db: DatabaseController!
	
	func loadRandomPhotos(for cards: [PhotoCard], callback: @escaping () -> Void) {
		let logger = Logger(subsystem: "Photos Loader", category: "PhotoController")
		logger.debug("Loading photos..")
		// Request permission to access photo library
		PHPhotoLibrary.requestAuthorization { status in
			switch status {
			case .authorized, .limited:
				Task {
					do {
						try await self.fetchRandomPhotos(for: cards)
						
						await MainActor.run {
							callback()
						}
					} catch {
						SentrySDK.capture(error: error)
						logger.critical("Failed to load photos. \(error)")
						
						await MainActor.run {
							if let error = error as? PhotoError {
								self.delegate?.didFail(error: error)
							}
						}
					}
				}
				
			default:
				DispatchQueue.main.async {
					SentrySDK.capture(error: PhotoError.noAccessToPhotoLibrary)
					self.delegate?.didFail(error: .noAccessToPhotoLibrary)
				}
			}
		}
	}

	func fetchRecentPhotos() async throws -> [PhotoCard] {
		// Get latest photo
		let fetchOptions = PHFetchOptions()
		fetchOptions.includeAssetSourceTypes = .typeUserLibrary
		fetchOptions.predicate = NSPredicate(format: "isHidden == NO AND (mediaType == %d OR mediaType == %d)",
																				 PHAssetMediaType.image.rawValue,
																				 PHAssetMediaType.video.rawValue)
		fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
		fetchOptions.fetchLimit = 1

		let fetchResult = PHAsset.fetchAssets(with: fetchOptions)

		if fetchResult.count == 0 {
			throw PhotoError.noPhotosAvailable
		}

		let card = PhotoCard()
		card.id = 0
		card.asset = fetchResult[0]
		return try await fetchPhotos(around: card)
	}

	func fetchPhotos(around card: PhotoCard) async throws -> [PhotoCard] {
		guard let asset = card.asset else {
			throw PhotoError.failedToFetchPhoto
		}

		let fetchOptions = PHFetchOptions()
		fetchOptions.includeAssetSourceTypes = .typeUserLibrary
		fetchOptions.predicate = NSPredicate(format: "isHidden == NO AND (mediaType == %d OR mediaType == %d)",
																				 PHAssetMediaType.image.rawValue,
																				 PHAssetMediaType.video.rawValue)

		// Fetch all photos
		let fetchResult = PHAsset.fetchAssets(with: fetchOptions)

		if fetchResult.count == 0 {
			throw PhotoError.noPhotosAvailable
		}

		let index = fetchResult.index(of: asset)
		if index == NSNotFound {
			throw PhotoError.failedToFetchPhoto
		}

		// Get before and after
		var cards: [PhotoCard] = []
		let from = max(0, index - 1)
		let to = min(fetchResult.count - 1, index + 1)

		var i = 0
		for resultIndex in from...to {
			let asset = fetchResult.object(at: resultIndex)
			let card = PhotoCard()
			card.id = i
			card.asset = asset
			cards.append(card)

			// Create thumbnail options
			let thumbnailOptions = PHImageRequestOptions()
			thumbnailOptions.deliveryMode = .fastFormat
			thumbnailOptions.resizeMode = .fast
			thumbnailOptions.isSynchronous = false

			// Create full image options
			let fullImageOptions = PHImageRequestOptions()
			fullImageOptions.deliveryMode = .highQualityFormat
			fullImageOptions.resizeMode = .fast
			fullImageOptions.isSynchronous = false
			fullImageOptions.isNetworkAccessAllowed = true

			// Request thumbnail
			PHImageManager.default().requestImage(
				for: asset,
				targetSize: CGSize(width: 200, height: 200),
				contentMode: .aspectFill,
				options: thumbnailOptions
			) { thumbnailImage, thumbnailInfo in
				DispatchQueue.main.async {
					card.thumbnail = thumbnailImage ?? UIImage()
				}
			}

			// Request full quality image asynchronously
			PHImageManager.default().requestImage(
				for: asset,
				targetSize: PHImageManagerMaximumSize,
				contentMode: .aspectFit,
				options: fullImageOptions
			) { fullImage, fullImageInfo in
				DispatchQueue.main.async {
					card.fullImage = fullImage ?? UIImage()
				}
			}

			i += 1
		}

		return cards
	}

	private func fetchRandomPhotos(for cards: [PhotoCard]) async throws {
		// Create fetch options
		let fetchOptions = PHFetchOptions()
		fetchOptions.includeAssetSourceTypes = .typeUserLibrary
		fetchOptions.predicate = NSPredicate(format: "isHidden == NO AND (mediaType == %d OR mediaType == %d)",
																				 PHAssetMediaType.image.rawValue,
																				 PHAssetMediaType.video.rawValue)
		
		// Fetch all photos
		let fetchResult = PHAsset.fetchAssets(with: fetchOptions)
		
		if fetchResult.count == 0 {
			throw PhotoError.noPhotosAvailable
		}
		
		if await fetchResult.count == db.getTotalKept() {
			throw PhotoError.noPhotosLeft
		}
		
		for card in cards {
			// Pick a random photo
			var asset: PHAsset!
			var loops = 0
			while true {
				loops += 1
				if loops > 100 {
					SentrySDK.capture(message: "PhotosController: Looped 100 times and found no photos")
					throw PhotoError.noPhotosLeft
				}
				let randomIndex = Int.random(in: 0..<fetchResult.count)
				asset = fetchResult.object(at: randomIndex) as PHAsset
				
				if asset.sourceType.contains(.typeCloudShared) || asset.sourceType.contains(.typeiTunesSynced) {
					continue
				}
				
				if let oldPhoto = await db.getPhoto(id: asset.localIdentifier),
					 oldPhoto.choice != .skip {
					continue
				}
				
				break
			}
			
			card.asset = asset
			
			let photo = Photo(id: asset.localIdentifier)
			photo.creationDate = asset.creationDate
			photo.type = Photo.AssetType(rawValue: asset.mediaType.rawValue) ?? .unknown
			
			card.photo = photo
			
			let resources = PHAssetResource.assetResources(for: asset)
			var size = 0.0
			for resource in resources {
				size += resource.value(forKey: "fileSize") as? Double ?? 0
			}
			
			photo.size = size
			
			// Create thumbnail options
			let thumbnailOptions = PHImageRequestOptions()
			thumbnailOptions.deliveryMode = .fastFormat
			thumbnailOptions.resizeMode = .fast
			thumbnailOptions.isSynchronous = true
			
			// Create full image options
			let fullImageOptions = PHImageRequestOptions()
			fullImageOptions.deliveryMode = .highQualityFormat
			fullImageOptions.resizeMode = .fast
			fullImageOptions.isSynchronous = false
			fullImageOptions.isNetworkAccessAllowed = true
			
			// Request thumbnail
			PHImageManager.default().requestImage(
				for: asset,
				targetSize: CGSize(width: 200, height: 200),
				contentMode: .aspectFill,
				options: thumbnailOptions
			) { thumbnailImage, thumbnailInfo in
				DispatchQueue.main.async {
					self.delegate?.didLoadThumbnail(for: card, image: thumbnailImage ?? UIImage())
				}
			}
			
			// Request full quality image asynchronously
			PHImageManager.default().requestImage(
				for: asset,
				targetSize: PHImageManagerMaximumSize,
				contentMode: .aspectFit,
				options: fullImageOptions
			) { fullImage, fullImageInfo in
				DispatchQueue.main.async {
					self.delegate?.didLoadFullImage(for: card, image: fullImage ?? UIImage())
				}
			}
		}
	}
	
	func delete(cards: [PhotoCard], callback: @escaping (Bool) -> Void) {
		let assets = cards.compactMap { $0.asset }
		
		PHPhotoLibrary.shared().performChanges {
			PHAssetChangeRequest.deleteAssets(assets as NSFastEnumeration)
		} completionHandler: { success, error in
			if let error = error as? NSError {
				if error.code != PHPhotosError.userCancelled.rawValue {
					SentrySDK.capture(error: error)
				}

				os_log(.error, "⚠️ Could not delete photos. \(error)")
			}
			
			if !success {
				// Mark as skipped because the user likely pressed cancel
				for card in cards {
					if let photo = card.photo {
						photo.choice = .skip
						
						Task {
							await self.db.addPhoto(photo: photo)
						}
					}
				}
			}
			
			DispatchQueue.main.async {
				if !success {
					self.delegate?.didFail(error: .failedToDelete)
				}
				
				callback(success)
			}
		}
	}
	
	func getVideoPlayer(asset: PHAsset, callback: @escaping (AVPlayer) -> Void) {
		let fullVideoOptions = PHVideoRequestOptions()
		fullVideoOptions.deliveryMode = .automatic
		fullVideoOptions.isNetworkAccessAllowed = true
		
		PHCachingImageManager().requestPlayerItem(forVideo: asset, options: fullVideoOptions) { playerItem, args in
			DispatchQueue.main.async {
				callback(AVPlayer(playerItem: playerItem))
			}
		}
	}

	struct ShareItem: Identifiable {
		var data: Data
		var type: UTType

		var id: Data { data }
	}

	static func getFullImage(asset: PHAsset) async throws -> ShareItem? {
		return try await withCheckedThrowingContinuation { continuation in
			let logger = Logger(subsystem: "Photo", category: "ShareSheet Handler")
			logger.debug("Called Share Photo")
			let fullImageOptions = PHImageRequestOptions()
			fullImageOptions.deliveryMode = .highQualityFormat
			fullImageOptions.resizeMode = .exact
			fullImageOptions.isSynchronous = false
			fullImageOptions.isNetworkAccessAllowed = true

			// Request full quality image asynchronously
			PHImageManager.default().requestImageDataAndOrientation(for: asset, options: fullImageOptions) { imageData, dataUTI, orientation, info in
				if let error = info?[PHImageErrorKey] as? Error {
					SentrySDK.capture(error: error)
					continuation.resume(throwing: error)
					return
				}

				guard let data = imageData,
							let type = UTType(dataUTI ?? "") else {
					continuation.resume(throwing: NSError(domain: "PhotoTransfer", code: 1, userInfo: [NSLocalizedDescriptionKey: "Could not load photo data"]))
					SentrySDK.capture(message: "Could not load photo data")
					logger.error("Could not load photo data")
					return
				}

				logger.debug("Opening ShareSheet..")
				// For most cases, we can use the data directly
				continuation.resume(returning: ShareItem(data: data, type: type))
			}
		}
	}

	func getShareImage(asset: PHAsset) -> TransferableImage {
		return TransferableImage(asset: asset)
	}
	
	func getShareVideo(asset: PHAsset) -> TransferableVideo {
		return TransferableVideo(asset: asset)
	}
}
