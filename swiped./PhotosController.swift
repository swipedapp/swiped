//
//  PhotosController.swift
//  swiped.
//
//  Created by tobykohlhagen on 2/5/2025.
//

import UIKit
import Photos
import CoreTransferable

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
	
	func loadRandomPhotos(for cards: [PhotoCard], callback: @escaping () -> Void) {
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
						print("error loading photos for cards: \(error)")
						
						await MainActor.run {
							if let error = error as? PhotoError {
								self.delegate?.didFail(error: error)
							}
						}
					}
				}
				
			default:
				DispatchQueue.main.async {
					self.delegate?.didFail(error: .noAccessToPhotoLibrary)
				}
			}
		}
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
		
		if fetchResult.count == DatabaseController.shared.getTotalKept() {
			throw PhotoError.noPhotosLeft
		}
		
		for card in cards {
			// Pick a random photo
			var asset: PHAsset!
			while true {
				let randomIndex = Int.random(in: 0..<fetchResult.count)
				asset = fetchResult.object(at: randomIndex) as PHAsset
				
				if asset.sourceType.contains(.typeCloudShared) || asset.sourceType.contains(.typeiTunesSynced) {
					continue
				}
				
				if let oldPhoto = DatabaseController.shared.getPhoto(id: asset.localIdentifier),
					 oldPhoto.choice != .skip {
					continue
				}
				
				break
			}
			
			card.asset = asset
			
			let photo = Photo(id: asset.localIdentifier)
			photo.creationDate = asset.creationDate
			photo.type = asset.mediaType
			
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
				print("Error deleting: \(error)")
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
	
//	func getShareVideo(asset: PHAsset) -> NSItemProvider {
//		let provider = NSItemProvider()
//		
//		// Register a type and loading handler
//		provider.registerDataRepresentation(forTypeIdentifier: UTType.movie.identifier, visibility: .all) { completion in
//			let progress = Progress()
//
//			let options = PHVideoRequestOptions()
//			options.version = .original
//			options.deliveryMode = .highQualityFormat
//			options.isNetworkAccessAllowed = true
//			
//			let requestID = PHImageManager.default().requestAVAsset(forVideo: asset, options: options) { asset, audioMix, info in
//				guard let asset = asset as? AVURLAsset else {
//					completion(nil, NSError(domain: "VideoShare", code: 1, userInfo: nil))
//					return
//				}
//				
//				// Create a temporary file URL
//				let temporaryDirectoryURL = FileManager.default.temporaryDirectory
//				let temporaryFileURL = temporaryDirectoryURL
//					.appendingPathComponent(UUID().uuidString)
//					.appendingPathExtension("mp4")
//				
//				// Use AVAssetExportSession to export the video
//				guard let exportSession = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetHighestQuality) else {
//					completion(nil, NSError(domain: "VideoShare", code: 2, userInfo: nil))
//					return
//				}
//				
//				exportSession.outputURL = temporaryFileURL
//				exportSession.outputFileType = .mp4
//				
//				exportSession.exportAsynchronously {
//					if exportSession.status == .completed,
//						 let data = try? Data(contentsOf: temporaryFileURL) {
//						completion(data, nil)
//					} else {
//						completion(nil, exportSession.error ?? NSError(domain: "VideoShare", code: 3, userInfo: nil))
//					}
//				}
//			}
//			
//			return progress
//		}
//		
//		return provider
//	}
	
	func getShareVideo(asset: PHAsset) -> TransferableVideo {
		return TransferableVideo(asset: asset)
	}
}

struct TransferableVideo: Transferable {
	let asset: PHAsset
	
	static var transferRepresentation: some TransferRepresentation {
		DataRepresentation(exportedContentType: .mpeg4Movie) { video in
			return try await withCheckedThrowingContinuation { continuation in
				let options = PHVideoRequestOptions()
				options.version = .original
				options.deliveryMode = .highQualityFormat
				options.isNetworkAccessAllowed = true
				
				PHImageManager.default().requestAVAsset(forVideo: video.asset, options: options) { avAsset, _, _ in
					guard let urlAsset = avAsset as? AVURLAsset else {
						continuation.resume(throwing: NSError(domain: "VideoTransfer", code: 1, userInfo: [NSLocalizedDescriptionKey: "Could not load video"]))
						return
					}
					
					// Create a temporary file URL
					let temporaryDirectoryURL = FileManager.default.temporaryDirectory
					let temporaryFileURL = temporaryDirectoryURL
						.appendingPathComponent(UUID().uuidString)
						.appendingPathExtension("mp4")
					
					// Export the video
					guard let exportSession = AVAssetExportSession(asset: urlAsset, presetName: AVAssetExportPresetHighestQuality) else {
						continuation.resume(throwing: NSError(domain: "VideoTransfer", code: 2, userInfo: [NSLocalizedDescriptionKey: "Could not create export session"]))
						return
					}
					
					exportSession.outputURL = temporaryFileURL
					exportSession.outputFileType = .mp4
					
					exportSession.exportAsynchronously {
						if exportSession.status == .completed {
							do {
								let data = try Data(contentsOf: temporaryFileURL)
								continuation.resume(returning: data)
								
								// Clean up temporary file
								try? FileManager.default.removeItem(at: temporaryFileURL)
							} catch {
								continuation.resume(throwing: error)
							}
						} else if let error = exportSession.error {
							continuation.resume(throwing: error)
						} else {
							continuation.resume(throwing: NSError(domain: "VideoTransfer", code: 3, userInfo: [NSLocalizedDescriptionKey: "Export failed"]))
						}
					}
				}
			}
		}
	}
}
