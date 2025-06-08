//
//  CherController.swift
//  swiped.
//
//  Created by Adam Demasi on 7/6/2025.
//

import SwiftUI
import UniformTypeIdentifiers

struct CherSource: Identifiable {
	var name: String
	var image: Image
	var isAvailable: () -> Bool
	var share: (CardInfo, PhotosController) async -> Void

	var id: String { name }
}

class CherController {

	static let sources = [
		CherSource(name: "Snapchat",
							 image: Image("snap"),
							 isAvailable: {
								 return UIApplication.shared.canOpenURL(URL(string: "snapchat://")!)
							 },
							 share: { cardInfo, photosController in
								 if let (data, type) = try? await getData(cardInfo: cardInfo, photosController: photosController) {
									 CreativeKit.shareToPreview(
										clientID: Identifiers.CLIENT_ID,
										mediaType: type.isSubtype(of: .video) ? .video : .image,
										mediaData: data
									 )
								 }
							 }),
		/*
		CherSource(name: "Bluesky",
							 image: Image("bluesky"),
							 isAvailable: {
								 return UIApplication.shared.canOpenURL(URL(string: "bluesky://")!)
							 },
							 share: { cardInfo, photosController in
								 // TODO
							 }),
		CherSource(name: "Ivory",
							 image: Image("ivory"),
							 isAvailable: {
								 return UIApplication.shared.canOpenURL(URL(string: "ivory://")!)
							 },
							 share: { cardInfo, photosController in
								 // TODO
							 }),
		CherSource(name: "Instagram",
							 image: Image("ig"),
							 isAvailable: {
								 return UIApplication.shared.canOpenURL(URL(string: "instagram://")!)
							 },
							 share: { cardInfo, photosController in
								 // TODO
							 }),

		CherSource(name: "Facebook",
							 image: Image("fb"),
							 isAvailable: {
								 return UIApplication.shared.canOpenURL(URL(string: "fb://")!)
							 },
							 share: { cardInfo, photosController in
								 // TODO
							 })
		 */
	]

	static let hasAnySources = {
		let count = sources.count(where: { $0.isAvailable() })
		return count > 0
	}()

	private static let dateFormatter: DateFormatter = {
		let dateFormatter = DateFormatter()
		dateFormatter.dateStyle = .medium
		return dateFormatter
	}()

	static func shareLink(cardInfo: CardInfo, photosController: PhotosController, body: () -> some View) -> some View {
		let card = cardInfo.card
		let asset = card?.asset
		let preview = SharePreview(Self.dateFormatter.string(from: asset?.creationDate ?? .distantPast),
															 image: Image(uiImage: card?.thumbnail ?? UIImage()))
		if let asset = asset {
			if asset.mediaType == .image {
				return AnyView(ShareLink(
					item: photosController.getShareImage(asset: asset),
					preview: preview,
					label: body
				))
			} else {
				return AnyView(ShareLink(
					item: photosController.getShareVideo(asset: asset),
					preview: preview,
					label: body
				))
			}
		} else {
			// Fake button for testing
			return AnyView(Button(action: {}, label: body))
		}
	}

	static func getData(cardInfo: CardInfo, photosController: PhotosController) async throws -> (Data, UTType)? {
		if #available(iOS 18.2, *) {
			guard let asset = cardInfo.card?.asset else {
				return nil
			}

			switch asset.mediaType {
			case .image:
				return try await PhotosController.getFullImage(asset: asset)

			case .video:
				return (try await photosController.getShareVideo(asset: asset).exported(as: .mpeg4Movie), .mpeg4Movie)

			case .unknown, .audio:
				return nil

			@unknown default:
				return nil
			}
		} else {
			return nil
		}
	}

}
