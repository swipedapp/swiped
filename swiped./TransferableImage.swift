//
//  TransferableImage.swift
//  swiped.
//
//  Created by tobykohlhagen on 20/5/2025.
//

import CoreTransferable
import Photos

struct TransferableImage: Transferable {
	let asset: PHAsset
	
	static var transferRepresentation: some TransferRepresentation {
		DataRepresentation(exportedContentType: .jpeg) { item in
			return try await withCheckedThrowingContinuation { continuation in
				let fullImageOptions = PHImageRequestOptions()
				fullImageOptions.deliveryMode = .highQualityFormat
				fullImageOptions.resizeMode = .exact
				fullImageOptions.isSynchronous = false
				fullImageOptions.isNetworkAccessAllowed = true
				
				// Request full quality image asynchronously
				PHImageManager.default().requestImageDataAndOrientation(for: item.asset, options: fullImageOptions) { imageData, dataUTI, orientation, info in
					if let error = info?[PHImageErrorKey] as? Error {
						continuation.resume(throwing: error)
						return
					}
					
					guard let data = imageData else {
						continuation.resume(throwing: NSError(domain: "PhotoTransfer", code: 1, userInfo: [NSLocalizedDescriptionKey: "Could not load photo data"]))
						return
					}
					
					// For most cases, we can use the data directly
					continuation.resume(returning: data)
				}
			}
		}
	}
}
