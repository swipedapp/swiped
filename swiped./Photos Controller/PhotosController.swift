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

	// MARK: - Internal helpers

	private static func fetchAssets(_ options: ((PHFetchOptions) -> Void)? = nil) throws -> PHFetchResult<PHAsset> {
		let fetchOptions = PHFetchOptions()
		fetchOptions.includeAssetSourceTypes = .typeUserLibrary
		fetchOptions.predicate = NSPredicate(format: "isHidden == NO AND (mediaType == %d OR mediaType == %d)",
																				 PHAssetMediaType.image.rawValue,
																				 PHAssetMediaType.video.rawValue)

		options?(fetchOptions)

		let fetchResult = PHAsset.fetchAssets(with: fetchOptions)

		if fetchResult.count == 0 {
			throw PhotoError.noPhotosAvailable
		}

		return fetchResult
	}

	private static func loadAssetImages(asset: PHAsset, thumbnail: ((UIImage) -> Void)? = nil, fullImage: ((UIImage) -> Void)? = nil, fullImageData: ((Data, UTType) -> Void)? = nil) {
		Task {
			if let thumbnail = thumbnail {
				// Create thumbnail options
				let thumbnailOptions = PHImageRequestOptions()
				thumbnailOptions.deliveryMode = .fastFormat
				thumbnailOptions.resizeMode = .fast
				thumbnailOptions.isSynchronous = true

				// Request thumbnail
				PHImageManager.default().requestImage(
					for: asset,
					targetSize: CGSize(width: 200, height: 200),
					contentMode: .aspectFill,
					options: thumbnailOptions
				) { image, info in
					DispatchQueue.main.async {
						thumbnail(image ?? UIImage())
					}
				}
			}

			if let fullImage = fullImage {
				// Create full image options
				let fullImageOptions = PHImageRequestOptions()
				fullImageOptions.deliveryMode = .highQualityFormat
				fullImageOptions.resizeMode = .fast
				fullImageOptions.isSynchronous = false
				fullImageOptions.isNetworkAccessAllowed = true

				// Request full quality image asynchronously
				PHImageManager.default().requestImage(
					for: asset,
					targetSize: PHImageManagerMaximumSize,
					contentMode: .aspectFit,
					options: fullImageOptions
				) { image, info in
					DispatchQueue.main.async {
						fullImage(image ?? UIImage())
					}
				}
			}
		}
	}

	// MARK: - Load photos

	private static let photosToFetchAround = 20

	func fetchRecentPhotos() async throws -> [PhotoCard] {
		// Get latest photo
		let fetchResult = try Self.fetchAssets { options in
			options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
			options.fetchLimit = 1
		}

		let card = PhotoCard()
		card.id = 0
		card.asset = fetchResult[0]
		return try await fetchPhotosAround(card: card)
	}

	func fetchPhotosAround(card: PhotoCard) async throws -> [PhotoCard] {
		guard let asset = card.asset else {
			throw PhotoError.failedToFetchPhoto
		}

		// Fetch all photos
		let fetchResult = try Self.fetchAssets()

		let index = fetchResult.index(of: asset)
		if index == NSNotFound {
			throw PhotoError.failedToFetchPhoto
		}

		// Get before and after
		var cards: [PhotoCard] = []
		let from = max(0, index - Self.photosToFetchAround)
		let to = min(fetchResult.count - 1, index + Self.photosToFetchAround)

		var i = 0
		for resultIndex in from...to {
			let asset = fetchResult.object(at: resultIndex)
			let card = PhotoCard()
			card.id = i
			card.asset = asset
			cards.append(card)

			Self.loadAssetImages(asset: asset, thumbnail: { image in
				card.thumbnail = image
			}, fullImage: { image in
				card.fullImage = image
			})

			i += 1
		}

		return cards
	}

	func loadRandomPhotos(for cards: [PhotoCard]) async throws {
		try await withCheckedThrowingContinuation { continuation in
			let logger = Logger(subsystem: "Photos Loader", category: "PhotoController")
			logger.debug("Loading photos..")
			// Request permission to access photo library

			PHPhotoLibrary.requestAuthorization { status in
				switch status {
				case .authorized, .limited:
					Task {
						do {
							try await self.fetchRandomPhotos(for: cards)
							continuation.resume()
						} catch {
							SentrySDK.capture(error: error)
							logger.critical("Failed to load photos. \(error)")
							continuation.resume(throwing: PhotoError.noAccessToPhotoLibrary)
						}
					}

				default:
					SentrySDK.capture(error: PhotoError.noAccessToPhotoLibrary)
					continuation.resume(throwing: PhotoError.noAccessToPhotoLibrary)
				}
			}
		}
	}

	private func fetchRandomPhotos(for cards: [PhotoCard]) async throws {
		// Fetch all photos
		let fetchResult = try Self.fetchAssets()

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

			Self.loadAssetImages(asset: asset, thumbnail: { image in
				card.thumbnail = image
			}, fullImage: { image in
				card.fullImage = image
			})
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
							// Disabled in showcase mode
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

	// MARK: - Sharing

	struct ShareItem: Identifiable {
		var data: Data
		var type: UTType

		var id: Data { data }
	}

	static func getFullImage(asset: PHAsset) async throws -> ShareItem? {
		return try await withCheckedThrowingContinuation { continuation in
			let logger = Logger(subsystem: "Photo", category: "ShareSheet Handler")
			logger.debug("Called Share Photo")

			Self.loadAssetImages(asset: asset, thumbnail: nil, fullImage: { image in
			})
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
