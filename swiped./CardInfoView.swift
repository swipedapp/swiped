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
import Sentry

class CardInfo: ObservableObject {
	@Published var summary = false
	@Published var position = 0
	@Published var card: PhotoCard?

	init(summary: Bool = false) {
		self.summary = summary
	}

	func setCard(_ card: PhotoCard?, position: Int, summary: Bool) {
		withAnimation {
			self.card = card
			self.position = position
			self.summary = summary
		}
	}

	func setSummary(_ summary: Bool) {
		withAnimation {
			self.summary = summary
		}
	}
}

struct CardInfoView: View {
	
	private static let dateFormatter: DateFormatter = {
		let dateFormatter = DateFormatter()
		dateFormatter.dateStyle = .medium
		return dateFormatter
	}()
	
	private static let fileSizeFormatter = ByteCountFormatter()
	
	private let photosController = PhotosController()

	var logo = false

	@EnvironmentObject var cardInfo: CardInfo
	
	@Environment(\.modelContext) var modelContext {
		didSet {
			photosController.db = DatabaseController(modelContainer: modelContext.container)
		}
	}
	
	@State var showSettings = false

	@State private var trigger = 0

	@AppStorage("timestamps")
	var timestamps = false
	
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
			icon = "camera.metering.unknown"
		@unknown default:
			icon = "camera.metering.unknown"
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
		types.append(Self.fileSizeFormatter.string(fromByteCount: Int64(photo.size)))
		if asset.mediaSubtypes.contains(.photoHDR) {
			types.append("HDR")
		}
		if asset.mediaSubtypes.contains(.photoPanorama) {
			types.append("Panorama")
		}
		if asset.mediaSubtypes.contains(.photoDepthEffect) {
			types.append("Portrait")
		}
		if asset.mediaSubtypes.contains(.spatialMedia) {
			types.append("Spatial")
		}
		if asset.mediaSubtypes.contains(.videoCinematic) {
			types.append("Cinematic")
		}
		if asset.mediaSubtypes.contains(.videoHighFrameRate) {
			types.append("Slo-mo")
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
			types.append("Burst")
		}
		
		/// Deprecated in favor of having icons sit next to their parent icon.
		/*
		 if asset.mediaSubtypes.contains(.photoScreenshot) {
		 types.append("Screenshot")
		 }
		 if asset.mediaSubtypes.contains(.photoLive) {
		 types.append("Live")
		 }
		 */
		
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
			}
		}
		
		
		
		return types.joined(separator: ", ")
	}

	var title: AnyView {
		if logo {
			return AnyView((Text("SWIPED") + Text(".")
				.foregroundColor(Color("brandGreen")))
				.contentTransition(.opacity))
		}

		let view: AnyView
		if let asset = cardInfo.card?.asset {
			let text: Text
			let date = asset.creationDate ?? .distantPast
			if timestamps {
				text = Text(date, format: Date.RelativeFormatStyle(presentation: .numeric, unitsStyle: .wide))
			} else {
				text = Text(date, format: Date.FormatStyle(date: .abbreviated))
			}
			view = AnyView(text
				.contentTransition(.numericText(value: -date.timeIntervalSince1970)))
		} else {
			view = AnyView(Text(" "))
		}

		return AnyView(view
			.textCase(.uppercase))
	}
	
	var subhead: AnyView {
		if logo {
			if cardInfo.summary {
				return AnyView(Text("Summary"))
			} else {
				return AnyView(Text(" "))
			}
		}

		if let asset = cardInfo.card?.asset {
			return AnyView(HStack(alignment: .center, spacing: 8) {
				Image(systemName: icon)
					.frame(width: 20, height: 20, alignment: .center)
				
				/// this looks ugly, if theres a way to fix this with a switch statement, lmk
				if asset.mediaSubtypes.contains(.photoScreenshot) {
					Image(systemName: "camera.viewfinder")
						.accessibilityLabel("Screenshot")
						.frame(width: 20, height: 20, alignment: .center)
				}
				
				if asset.mediaSubtypes.contains(.photoLive) {
					Image(systemName: "livephoto")
						.accessibilityLabel("Live")
						.frame(width: 20, height: 20, alignment: .center)
				}
				
				
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
				let resources = PHAssetResource.assetResources(for: asset)
				if let resource = resources.first {
					let fileName = resource.originalFilename
					
					if !fileName.starts(with: "IMG_") && !asset.mediaSubtypes.contains(.screenRecording) {
						Image(systemName: "square.and.arrow.down")
							.accessibilityLabel("Edited")
							.frame(width: 20, height: 20, alignment: .center)
					}
				}
				Text(type)
					.contentTransition(.numericText())
			})
			
		}
		return AnyView(Text(" "))

	}
	
	var shareButton: some View {
		Button(action: {}, label: {
			Image(systemName: "square.and.arrow.up")
				.font(.custom("LoosExtended-Bold", size: 20))
				.frame(width: 40, height: 40, alignment: .center)
		})
		.contextMenu {
			Button(action: {
				if let data = cardInfo.card?.fullImage!.pngData() {
					//self.delegate?.didTapButton(action: action)
					CreativeKit.shareToPreview(
						clientID: Identifiers.CLIENT_ID,
						mediaType: .image,
						mediaData: data
					)
				}
			}, label: {
				Text("Snapchat")
			})
			
			shareLink
		}
	}
	
	var shareLink: some View {
		if !logo,
			 let card = cardInfo.card,
			 let asset = card.asset,
			 asset.mediaType == .image || asset.mediaType == .video {
			let preview =  SharePreview(Self.dateFormatter.string(from: asset.creationDate ?? .distantPast),
																	image: Image(uiImage: card.thumbnail ?? UIImage()))
			if asset.mediaType == .image {
				return AnyView(ShareLink(
					item: photosController.getShareImage(asset: asset),
					preview: preview
				) {
					Text("Share…")
				})
			} else {
				return AnyView(ShareLink(
					item: photosController.getShareVideo(asset: asset),
					preview: preview
				) {
					Text("Share…")
				})
			}
		} else {
			return AnyView(EmptyView())
		}
	}
	
	var body: some View {
		VStack(alignment: .leading, spacing: 4) {
			HStack(alignment: .lastTextBaseline, spacing: 0) {
				title
					.id("title")
					.font(.custom("LoosExtended-Bold", size: 24))
					.lineLimit(1)
					.onTapGesture {
						timestamps = !timestamps

					}

				Spacer()

				shareButton

				Button(action: {
					showSettings = true
				}, label: {
					Image(systemName: "gear")
						.font(.custom("LoosExtended-Bold", size: 20))
				})
				.frame(width: 40, height: 40, alignment: .center)
				.accessibilityIdentifier("settingsButton")
			}

			subhead
				.id("subhead")
				.font(.custom("LoosExtended-Regular", size: 18))
				.lineLimit(1)
		}
		.padding(.horizontal, 20)
		.frame(height: 77)
		.foregroundColor(.primary)
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
