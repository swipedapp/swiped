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
		if let asset = card.asset,
			 asset.mediaType == .video {
			VideoPlayer(player: player)
				.ignoresSafeArea(.all, edges: .all)
				.background(.black)
				.presentationBackground(.black)
				.task {
					// Get the player
					photosController.getVideoPlayer(asset: asset) { player in
						self.player = player
						try? AVAudioSession.sharedInstance().setCategory(.playback)
						player.play()
					}
				}
				.onDisappear {
					// Stop playing
					player?.replaceCurrentItem(with: nil)
				}
		} else {
			let image = card.fullImage ?? card.thumbnail ?? UIImage()

			GeometryReader { geometry in
				Zoomable {
					ZStack {
						Image(uiImage: image)
							.resizable()
							.scaledToFit()
							.frame(width: geometry.size.width,
										 height: geometry.size.height,
										 alignment: .center)
							.aspectRatio(contentMode: .fit)
							.ignoresSafeArea(.all, edges: .all)
							.background(.black)

						if card.fullImage == nil {
							ProgressView()
								.controlSize(.large)
								.tint(.white)
								.shadow(color: .black.opacity(0.5),
												radius: 2,
												x: 0, y: 0)
						}
					}
				}
				.ignoresSafeArea(.all, edges: .all)
				.background(.black)
			}
				.ignoresSafeArea(.all, edges: .all)
				.background(.black)
				.presentationBackground(.black)
		}
	}
}

#Preview {
	let card = PhotoCard(id: 0, photo: nil, asset: nil, fullImage: UIImage(named: "IMG_2871.jpg"))
	FullScreenView()
		.environmentObject(card)
}

