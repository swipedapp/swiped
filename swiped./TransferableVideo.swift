//
//  TransferableVideo.swift
//  swiped.
//
//  Created by tobykohlhagen on 20/5/2025.
//

import CoreTransferable
import Photos

struct TransferableVideo: Transferable {
	let asset: PHAsset
	
	static var transferRepresentation: some TransferRepresentation {
		DataRepresentation(exportedContentType: .mpeg4Movie) { item in
			return try await withCheckedThrowingContinuation { continuation in
				let options = PHVideoRequestOptions()
				options.version = .original
				options.deliveryMode = .highQualityFormat
				options.isNetworkAccessAllowed = true
				
				PHImageManager.default().requestAVAsset(forVideo: item.asset, options: options) { avAsset, _, _ in
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
