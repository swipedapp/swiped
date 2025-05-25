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
	
	private static let dateFormatter: DateFormatter = {
		let dateFormatter = DateFormatter()
		dateFormatter.dateStyle = .medium
		return dateFormatter
	}()
	
	private static let fileSizeFormatter = ByteCountFormatter()
	
	private let photosController = PhotosController()
	
	@EnvironmentObject var cardInfo: CardInfo
	
	@State var showSettings = false
	
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
			types.append("HDR")
		}
		if asset.mediaSubtypes.contains(.photoLive) {
			types.append("Live Photo")
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
			let date = asset.creationDate ?? .distantPast
			let view: AnyView
			if timestamps {
				view = AnyView(Text(date, format: Date.RelativeFormatStyle(presentation: .numeric, unitsStyle: .wide)))
			} else {
				view = AnyView(Text(date, format: Date.FormatStyle(date: .abbreviated)))
			}
			
			if #available(iOS 17, *) {
				return AnyView(view
					.textCase(.uppercase)
					.contentTransition(.numericText(value: -date.timeIntervalSince1970)))
			} else {
				return AnyView(view
					.textCase(.uppercase)
					.contentTransition(.numericText()))
			}
		} else {
			return AnyView(Text("SWIPED") + Text(".")
				.foregroundColor(Color("brandGreen")))
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
		
		return AnyView(EmptyView()
			.frame(height: 20))
	}
	
	var shareButton: some View {
		if let card = cardInfo.card,
			 let asset = card.asset,
			 asset.mediaType == .image || asset.mediaType == .video {
			let preview =  SharePreview(Self.dateFormatter.string(from: asset.creationDate ?? .distantPast),
																	image: Image(uiImage: card.thumbnail ?? UIImage()))
			if asset.mediaType == .image {
				return AnyView(ShareLink(
					item: photosController.getShareImage(asset: asset),
					preview: preview
				) {
					Image(systemName: "square.and.arrow.up")
				}
					.font(.custom("LoosExtended-Bold", size: 20))
					.frame(width: 40, height: 40, alignment: .center))
			} else {
				return AnyView(ShareLink(
					item: photosController.getShareVideo(asset: asset),
					preview: preview
				) {
					Image(systemName: "square.and.arrow.up")
				}
					.font(.custom("LoosExtended-Bold", size: 20))
					.frame(width: 40, height: 40, alignment: .center))
			}
		} else {
			return AnyView(EmptyView())
		}
	}
	
	var body: some View {
//			ZStack {
				VStack(alignment: .leading, spacing: 4) {
					HStack(alignment: .lastTextBaseline, spacing: 0) {
						title
							.font(.custom("LoosExtended-Bold", size: 24))
							.onTapGesture {
								timestamps = !timestamps
							}
						
						Spacer()
						
						shareButton
						
						if cardInfo.summary || cardInfo.card?.asset != nil {
							Button(action: {
								showSettings = true
							}, label: {
								Image(systemName: "gear")
									.font(.custom("LoosExtended-Bold", size: 20))
							})
							.frame(width: 40, height: 40, alignment: .center)
						}
					}
					
					subhead
						.font(.custom("LoosExtended-Regular", size: 18))
						.contentTransition(.numericText())
				}
				.padding(.horizontal, 20)
				.padding(.vertical, 18)
				.foregroundColor(.primary)
				.sheet(isPresented: $showSettings) {
					SettingsView()
				}
				
				// branding overlay positioned near dynamic island
//				VStack {
//					HStack {
//						Spacer()
//						Text("swiped.")
//							.font(.system(size: 11, weight: .medium, design: .monospaced))
//							.foregroundColor(.white.opacity(0.9))
//							.shadow(color: .black.opacity(0.3), radius: 1, x: 0, y: 1)
//							.padding(.top, 15) // closer to dynamic island
//						Spacer()
//					}
//					Spacer()
//				}
//				.ignoresSafeArea(.all, edges: .top)
//			}
		}
}

#Preview {
	let cardInfo = CardInfo()
	cardInfo.card = PhotoCard()
	
	return CardInfoView()
		.environmentObject(cardInfo)
}
