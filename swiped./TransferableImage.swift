//
//  TransferableImage.swift
//  swiped.
//
//  Created by tobykohlhagen on 20/5/2025.
//


import CoreTransferable
import Photos
import OSLog
import Sentry

struct TransferableImage: Transferable {
	let asset: PHAsset
	
	static var transferRepresentation: some TransferRepresentation {
		DataRepresentation(exportedContentType: .jpeg) { item in
			if let item = try await PhotosController.getFullImage(asset: item.asset) {
				return item.data
			}
			return Data()
		}
	}
}
