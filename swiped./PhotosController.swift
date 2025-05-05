//
//  PhotosController.swift
//  swiped.
//
//  Created by tobykohlhagen on 2/5/2025.
//

import UIKit
import Photos

class PhotosController {
	
	protocol PhotoLoadDelegate: AnyObject {
		func didLoadThumbnail(for card: PhotoCard, image: UIImage)
		func didLoadFullImage(for card: PhotoCard, image: UIImage)
		func didFail(error: PhotoError)
	}
		
	enum PhotoError: Error {
		case noAccessToPhotoLibrary
		case noPhotosAvailable
		case failedToFetchPhoto
		case failedToDelete
	}
		
	weak var delegate: PhotoLoadDelegate?
		
	func loadRandomPhoto(for card: PhotoCard, callback: @escaping (UIImage) -> Void) {
		// Request permission to access photo library
		PHPhotoLibrary.requestAuthorization { [weak self] status in
			guard let self = self else { return }
			
			switch status {
			case .authorized, .limited:
				self.fetchRandomPhoto(for: card, callback: callback)
			default:
				DispatchQueue.main.async {
					self.delegate?.didFail(error: .noAccessToPhotoLibrary)
				}
			}
		}
	}
		
	private func fetchRandomPhoto(for card: PhotoCard, callback: @escaping (UIImage) -> Void) {
		// Create fetch options
		let fetchOptions = PHFetchOptions()
		fetchOptions.includeAssetSourceTypes = .typeUserLibrary
		fetchOptions.predicate = NSPredicate(format: "isHidden == NO AND (mediaType == %d OR mediaType == %d)",
																				 PHAssetMediaType.image.rawValue,
																				 PHAssetMediaType.video.rawValue)

		// Fetch all photos
		let fetchResult = PHAsset.fetchAssets(with: fetchOptions)

		guard fetchResult.count > 0 else {
			DispatchQueue.main.async {
				self.delegate?.didFail(error: .noPhotosAvailable)
			}
			return
		}
		
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
				guard let thumbnailImage = thumbnailImage else {
					self.delegate?.didFail(error: .failedToFetchPhoto)
					return
				}
				
				self.delegate?.didLoadThumbnail(for: card, image: thumbnailImage)
				callback(thumbnailImage)
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
				guard let fullImage = fullImage else {
					self.delegate?.didFail(error: .failedToFetchPhoto)
					return
				}
				
				self.delegate?.didLoadFullImage(for: card, image: fullImage)
			}
		}
	}
	
	func delete(cards: [PhotoCard], callback: @escaping () -> Void) {
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

				callback()
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
}
