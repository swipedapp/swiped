//
//  CardContentView.swift
//  swiped.
//
//  Created by tobykohlhagen on 2/5/2025.
//

import UIKit
import SwiftUI
import OSLog

struct CardContentView: View {

	@EnvironmentObject private var card: PhotoCard

	@State var isScaling = false
	@State var scale: CGFloat = 1

	var body: some View {
		let image = card.fullImage ?? card.thumbnail ?? UIImage()
		let background = isScaling ? Color(uiColor: .systemBackground) : Color.clear

		GeometryReader { geometry in
			background.overlay {
			ZStack {
				RoundedRectangle(cornerRadius: 8, style: .continuous)
					.fill(.black)

				Image(uiImage: image)
					.resizable()
					.scaledToFill()
					.frame(width: max(geometry.size.width - 50, 0),
								 height: max(geometry.size.height - 60, 0),
								 alignment: .center)
					.background(.black)
					.aspectRatio(contentMode: image.size.width > image.size.height ? .fit : .fill)
					.clipped()
					.clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))

				if card.asset?.mediaType == .video {
					Image(systemName: "play.circle")
						.font(.system(size: 48))
						.foregroundStyle(.white)
				}

				if card.fullImage == nil {
					ProgressView()
						.tint(.white)
						.shadow(color: .black, radius: 2, x: 0, y: 0)
				}
			}
				.padding(.horizontal, 25)
				.padding(.vertical, 30)
				.scaleEffect(scale)
				.gesture(MagnifyGesture()
						.onChanged({ value in
							isScaling = true
							scale = value.magnification
						})
						.onEnded({ value in
							withAnimation(.bouncy(duration: 0.3)) {
								scale = 1
							} completion: {
								isScaling = false
							}
						}))
			}
		}
	}

}

#Preview {
	let card = PhotoCard(id: 0, photo: nil, asset: nil, thumbnail: UIImage(named: "IMG_2871.HEIC"), fullImage: nil)
	CardContentView()
		.environmentObject(card)
}

class CardContentWrapperView: UIView {
	
	private let hostingController: UIHostingController<AnyView>

	let card: PhotoCard

	init(card: PhotoCard) {
		self.card = card

		hostingController = UIHostingController(rootView: AnyView(
			CardContentView()
				.environmentObject(card)
		))

		super.init(frame: .zero)

		hostingController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
		hostingController.view.isOpaque = false
		hostingController.view.backgroundColor = .clear
		hostingController.willMove(toParent: nil)
		addSubview(hostingController.view)
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

}
