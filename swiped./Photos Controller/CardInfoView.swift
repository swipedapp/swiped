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

struct CardInfoView: View {
	
	private static let fileSizeFormatter = ByteCountFormatter()
	
	private let photosController = PhotosController()

	var logo = false

	@EnvironmentObject var appState: AppState
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
		guard let photo = cardInfo.card?.photo else {
			return "photo"
		}

		var icon = "photo"

		switch photo.type {
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
		
		if let asset = cardInfo.card?.asset {
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
		}

		return icon
	}
	
	var type: String {
		guard let photo = cardInfo.card?.photo else {
			return ""
		}

		let asset = cardInfo.card?.asset
		let subtypes = asset?.mediaSubtypes ?? []

		var types = [String]()
		types.append(Self.fileSizeFormatter.string(fromByteCount: Int64(photo.size)))
		if subtypes.contains(.photoHDR) {
			types.append("HDR")
		}
		if subtypes.contains(.photoPanorama) {
			types.append("Panorama")
		}
		if subtypes.contains(.photoDepthEffect) {
			types.append("Portrait")
		}
		if subtypes.contains(.spatialMedia) {
			types.append("Spatial")
		}
		if subtypes.contains(.videoCinematic) {
			types.append("Cinematic")
		}
		if subtypes.contains(.videoHighFrameRate) {
			types.append("Slo-mo")
		}
		if subtypes.contains(.videoStreamed) {
			types.append("Streamed Video")
		}
		if subtypes.contains(.videoTimelapse) {
			types.append("Time Lapse")
		}
		if subtypes.contains(.screenRecording) {
			types.append("Screen Recording")
		}
		if asset?.burstIdentifier != nil {
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
			switch photo.type {
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

		if let asset = asset {
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
		}

		
		
		return types.joined(separator: ", ")
	}

	@ViewBuilder
	var title: some View {
		if logo {
			let dot = Text(".")
				.foregroundColor(Color("brandGreen"))

			Text("SWIPED\(dot)")
				.font(.custom("LoosExtended-Bold", size: 24))
				.contentTransition(.opacity)
		} else {
			if let photo = cardInfo.card?.photo {
				let date = photo.creationDate ?? .distantPast
				let text = timestamps
					? Text(date, format: Date.RelativeFormatStyle(presentation: .numeric, unitsStyle: .wide))
					: Text(date, format: Date.FormatStyle(date: .abbreviated))

				text
					.font(Fonts.title)
					.textCase(.uppercase)
					.contentTransition(.numericText(value: -date.timeIntervalSince1970))
			} else {
				Text(" ")
					.font(Fonts.title)
					.textCase(.uppercase)
			}
		}
	}

	@ViewBuilder
	var subhead: some View {
		if logo {
			if appState.summary {
				Text("Summary")
			} else {
				Text(" ")
			}
		} else {
			HStack(alignment: .center, spacing: 8) {
				Image(systemName: icon)
					.frame(width: 20, height: 20, alignment: .center)
				
				/// this looks ugly, if theres a way to fix this with a switch statement, lmk
				if let asset = cardInfo.card?.asset {
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
								.accessibilityLabel("Imported")
								.frame(width: 20, height: 20, alignment: .center)
						}
					}
				}

				Text(type)
					.contentTransition(.numericText())
			}
			
		}
	}
	
	var body: some View {
		VStack(alignment: .leading, spacing: 4) {
			HStack(alignment: .lastTextBaseline, spacing: 0) {
				title
					.id("title")
					.lineLimit(1)
					.onTapGesture {
						timestamps = !timestamps

					}

				Spacer()

				Button(action: {
					showSettings = true
				}, label: {
					Image(systemName: "gear")
						.font(.system(size: 20))
				})
				.frame(width: 44, height: 44, alignment: .center)
				.accessibilityLabel("Settings")
				.accessibilityIdentifier("settingsButton")
				.glassEffect(.regular.interactive())
			}

			subhead
				.id("subhead")
				.font(Fonts.subhead)
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
	let appState = AppState(summary: false)
	let cardInfo = CardInfo()
	cardInfo.card = PhotoCard()
	
	return CardInfoView()
		.environmentObject(appState)
		.environmentObject(cardInfo)
}
