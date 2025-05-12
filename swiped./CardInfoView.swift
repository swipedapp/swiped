//
//  CardInfoView.swift
//  swiped.
//
//  Created by tobykohlhagen on 5/5/2025.
//

import UIKit
import SwiftUI
import Photos
import UniformTypeIdentifiers

class CardInfo: ObservableObject {
	@Published var summary = false
	@Published var card: PhotoCard?
	
	func setCard(_ card: PhotoCard?, summary: Bool) {
		withAnimation {
			self.card = card
			self.summary = summary
		}
	}
}

struct CardInfoView: View {

	protocol Delegate: AnyObject {
		func share(sender: UIButton)
		func settings()
	}

	weak var delegate: Delegate?

	private static let dateFormatter: DateFormatter = {
		let dateFormatter = DateFormatter()
		dateFormatter.dateStyle = .medium
		return dateFormatter
	}()

	private static let fileSizeFormatter = ByteCountFormatter()

	@EnvironmentObject var cardInfo: CardInfo

	@State var showSettings = false

	var icon: String {
		guard let asset = cardInfo.card?.asset else {
			return ""
		}

		var icon = ""

		switch asset.mediaType {
		case .image:
			icon = "photo"
		case .video:
			icon = "video"
		case .audio:
			icon = "audio"
		case .unknown:
			icon = "questionmark.circle"
		@unknown default:
			icon = "questionmark.circle"
		}

		if asset.mediaSubtypes.contains(.photoScreenshot) {
			icon = "camera.viewfinder"
		}
		if asset.mediaSubtypes.contains(.photoLive) {
			icon = "livephoto"
		}
		if asset.mediaSubtypes.contains(.photoDepthEffect) {
			icon = "person.and.background.dotted"
		}
		if asset.mediaSubtypes.contains(.spatialMedia) {
			icon = "video"
		}
		if asset.mediaSubtypes.contains(.videoCinematic) {
			icon = "video"
		}
		if asset.mediaSubtypes.contains(.videoHighFrameRate) {
			icon = "video"
		}
		if asset.mediaSubtypes.contains(.videoStreamed) {
			icon = "video"
		}
		if asset.mediaSubtypes.contains(.videoTimelapse) {
			icon = "timelapse"
		}
		if asset.mediaSubtypes.contains(.screenRecording) {
			icon = "record.circle"
		}
		if asset.burstIdentifier != nil {
			icon = "square.stack.3d.down.forward"
		}

		return icon
	}

	var type: String {
		guard let photo = cardInfo.card?.photo,
					let asset = cardInfo.card?.asset else {
			return ""
		}

		var types = [String]()

		if asset.mediaSubtypes.contains(.photoScreenshot) {
			types.append("Screenshot")
		}
		if asset.mediaSubtypes.contains(.photoHDR) {
			types.append("HDR Photo")
		}
		if asset.mediaSubtypes.contains(.photoLive) {
			types.append("Live Photo")
		}
		if asset.mediaSubtypes.contains(.photoPanorama) {
			types.append("Panorama")
		}
		if asset.mediaSubtypes.contains(.photoDepthEffect) {
			types.append("Depth Effect")
		}
		if asset.mediaSubtypes.contains(.spatialMedia) {
			types.append("Spatial Media")
		}
		if asset.mediaSubtypes.contains(.videoCinematic) {
			types.append("Cinematic Video")
		}
		if asset.mediaSubtypes.contains(.videoHighFrameRate) {
			types.append("High Frame Rate Video")
		}
		if asset.mediaSubtypes.contains(.videoStreamed) {
			types.append("Streamed Video")
		}
		if asset.mediaSubtypes.contains(.videoTimelapse) {
			types.append("Time Lapse")
		}
		if asset.mediaSubtypes.contains(.screenRecording) {
			types.append("Screen Recording")
		}
		if asset.burstIdentifier != nil {
			types.append("Burst Photo")
		}

		if types.isEmpty {
			switch asset.mediaType {
			case .image:
				types.append("Photo")
			case .video:
				types.append("Video")
			case .audio:
				types.append("Audio")
			case .unknown:
				types.append("Unknown")
			@unknown default:
				types.append("Unknown")
			}
		}

		let resources = PHAssetResource.assetResources(for: asset)

		if resources.contains(where: { UTType($0.uniformTypeIdentifier)?.conforms(to: UTType.rawImage) == true }) {
			types.append("RAW")
		}

		if let resource = resources.first {
			let fileName = resource.originalFilename

			if fileName.starts(with: "telegram-") {
				types.append("Saved from Telegram")
			} else if !fileName.starts(with: "IMG_") && !asset.mediaSubtypes.contains(.screenRecording) {
				types.append("Imported")
			}
		}

		types.append(Self.fileSizeFormatter.string(fromByteCount: Int64(photo.size)))

		return types.joined(separator: ", ")
	}
	
	var title: AnyView {
		if let asset = cardInfo.card?.asset {
			return AnyView(Text(Self.dateFormatter.string(from: asset.creationDate ?? .distantPast))
				.contentTransition(.numericText()))
		} else {
			return AnyView(Text("SWIPED") + Text(".")
				.foregroundColor(.accentColor))
		}
	}
	
	var subhead: AnyView {
		if cardInfo.summary {
			return AnyView(HStack(alignment: .center, spacing: 8) {
				Text("Summary")
					.contentTransition(.numericText())
			})
		} else if let asset = cardInfo.card?.asset {
			return AnyView(HStack(alignment: .center, spacing: 8) {
				Image(systemName: icon)
					.frame(width: 20, height: 20, alignment: .center)
				
				if asset.isFavorite {
					Image(systemName: "heart.fill")
						.accessibilityLabel("Favorite")
						.frame(width: 20, height: 20, alignment: .center)
				}
				
				if asset.hasAdjustments {
					Image(systemName: "pencil")
						.accessibilityLabel("Edited")
						.frame(width: 20, height: 20, alignment: .center)
				}
				
				Text(type)
					.contentTransition(.numericText())
			})
		}
		
		return AnyView(EmptyView())
	}

	var body: some View {
		VStack(alignment: .leading, spacing: 4) {
			HStack(alignment: .lastTextBaseline, spacing: 0) {
				title
					.font(.custom("LoosExtended-Bold", size: 24))

				Spacer()


				if let asset = cardInfo.card?.asset,
					 asset.mediaType == .image {
					ShareLink(
						item: Image(uiImage: cardInfo.card?.fullImage ?? UIImage()),
						preview: SharePreview("", image: Image(uiImage: cardInfo.card?.thumbnail ?? UIImage()))
					) {
						Image(systemName: "square.and.arrow.up")
					}
						.font(.custom("LoosExtended-Bold", size: 20))
						.frame(width: 40, height: 40, alignment: .center)
				}


				Button(action: {
					showSettings = true
				}, label: {
					Image(systemName: "gear")
						.font(.custom("LoosExtended-Bold", size: 20))
				})
					.frame(width: 40, height: 40, alignment: .center)
			}

			subhead
				.font(.custom("LoosExtended-Regular", size: 18))
				.contentTransition(.numericText())
		}
			.padding(.horizontal, 20)
			.padding(.vertical, 18)
			.foregroundColor(.white)
			.sheet(isPresented: $showSettings) {
				SettingsView()
			}
	}

}

#Preview {
	let cardInfo = CardInfo()
	cardInfo.card = PhotoCard()

	return CardInfoView()
		.environmentObject(cardInfo)
}
