//
//  FullScreenView.swift
//  swiped.
//
//  Created by Adam Demasi on 16/6/2025.
//

import SwiftUI

struct FullScreenView: View {

	@EnvironmentObject var card: PhotoCard

	@Environment(\.presentationMode) var presentationMode

	var animation: Namespace.ID

	@State private var isScrolling = false
	@State private var offset = CGPoint.zero

	var body: some View {
		let image = card.fullImage ?? card.thumbnail ?? UIImage()

		GeometryReader { geometry in
			ScrollableImage(isScrolling: $isScrolling, offset: $offset) {
				Image(uiImage: image)
					.resizable()
					.scaledToFill()
					.frame(width: geometry.size.width,
								 height: geometry.size.height,
								 alignment: .center)
					.aspectRatio(contentMode: image.size.width > image.size.height ? .fit : .fill)
					.clipped()
			}
		}
			.backgroundStyle(.regularMaterial)
			.preferredColorScheme(.dark)
	}
}

#Preview {
	@Previewable @Namespace var animation

	let card = PhotoCard(id: 0, photo: nil, asset: nil, fullImage: UIImage(named: "IMG_2871.HEIC"))
	FullScreenView(animation: animation)
		.environmentObject(card)
}

