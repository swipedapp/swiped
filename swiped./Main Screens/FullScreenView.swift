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

	@State private var isScrolling = false
	@State private var offset = CGPoint.zero
	@State private var rect = CGRect.zero

	var body: some View {
		let image = card.fullImage ?? card.thumbnail ?? UIImage()

		GeometryReader { geometry in
			Zoomable {
				Image(uiImage: image)
					.resizable()
					.scaledToFit()
					.frame(width: geometry.size.width,
								 height: geometry.size.height,
								 alignment: .center)
					.aspectRatio(contentMode: .fit)
					.ignoresSafeArea(.all, edges: .all)
					.background(.black)
			}
				.ignoresSafeArea(.all, edges: .all)
				.background(.black)
		}
			.ignoresSafeArea(.all, edges: .all)
			.background(.black)
			.presentationBackground(.black)
	}
}

#Preview {
	let card = PhotoCard(id: 0, photo: nil, asset: nil, fullImage: UIImage(named: "IMG_2871.HEIC"))
	FullScreenView()
		.environmentObject(card)
}

