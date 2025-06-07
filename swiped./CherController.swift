//
//  CherController.swift
//  swiped.
//
//  Created by Adam Demasi on 7/6/2025.
//

import SwiftUI

struct CherSource: Identifiable {
	var name: String
	var image: Image
	var isAvailable: () -> Bool
	var share: (CardInfo) -> Void

	var id: String { name }
}

class CherController {

	static let sources = [
		CherSource(name: "Snapchat",
							 image: Image("snap"),
							 isAvailable: {
								 return UIApplication.shared.canOpenURL(URL(string: "snapchat://")!)
							 },
							 share: { cardInfo in
								if let data = cardInfo.card?.fullImage?.pngData() {
									CreativeKit.shareToPreview(
										clientID: Identifiers.CLIENT_ID,
										mediaType: .image,
										mediaData: data
									)
								}
							 }),

		CherSource(name: "Instagram",
							 image: Image("ig"),
							 isAvailable: {
								 return UIApplication.shared.canOpenURL(URL(string: "instagram://")!)
							 },
							 share: { cardInfo in
								 // TODO
							 }),

		CherSource(name: "Facebook",
							 image: Image("fb"),
							 isAvailable: {
								 return UIApplication.shared.canOpenURL(URL(string: "fb://")!)
							 },
							 share: { cardInfo in
								 // TODO
							 })
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

}
