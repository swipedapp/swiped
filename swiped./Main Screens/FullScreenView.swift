//
//  FullScreenView.swift
//  swiped.
//
//  Created by Adam Demasi on 16/6/2025.
//

import SwiftUI
import AVKit

struct FullScreenView: View {

	private let photosController = PhotosController()

	@Environment(\.modelContext) var modelContext {
		didSet {
			photosController.db = DatabaseController(modelContainer: modelContext.container)
		}
	}

	@EnvironmentObject var card: PhotoCard

	@Environment(\.presentationMode) var presentationMode

	@State private var player: AVPlayer?

	var body: some View {
		let image = card.fullImage ?? card.thumbnail ?? UIImage()

		GeometryReader { geometry in
			let imageView = Image(uiImage: image)
				.resizable()
				.scaledToFit()
				.frame(width: geometry.size.width,
							 height: geometry.size.height,
							 alignment: .center)
				.aspectRatio(contentMode: .fit)
				.ignoresSafeArea(.all, edges: .all)
				.background(.black)

			let progressView = ProgressView()
				.controlSize(.large)
				.tint(.white)
				.shadow(color: .black, radius: 1, x: 0, y: 0)
				.shadow(color: .black.opacity(0.5), radius: 2, x: 0, y: 0)

			if let asset = card.asset,
				 asset.mediaType == .video {
				VideoPlayer(player: player)
					.ignoresSafeArea(.all, edges: .all)
					.background(.black)
					.presentationBackground(.black)
					.task {
						// Get the player
						if let player = try? await photosController.getVideoPlayer(asset: asset) {
							self.player = player
							try? AVAudioSession.sharedInstance().setCategory(.playback)
							player.play()
						}
					}
					.onDisappear {
						// Stop playing
						player?.replaceCurrentItem(with: nil)
					}
					.overlay {
						if player == nil {
							imageView
							progressView
						}
					}
			} else {
				Zoomable {
					ZStack {
						imageView

						if card.fullImage == nil {
							progressView
						}
					}
				}
					.ignoresSafeArea(.all, edges: .all)
					.background(.black)
			}
		}
			.ignoresSafeArea(.all, edges: .all)
			.background(.black)
			.presentationBackground(.black)
	}
}

#Preview {
	let card = PhotoCard(id: 0, photo: nil, asset: nil, fullImage: UIImage(named: "IMG_2871.jpg"))
	FullScreenView()
		.environmentObject(card)
}

