//
//  CardOverlay.swift
//  swiped.
//
//  Created by tobykohlhagen on 2/5/2025.
//

import reShuffled
import UIKit
import SwiftUI

struct CardOverlay: View {

	var direction: SwipeDirection

	var stuff: (text: String, color: Color, edge: Edge.Set, alignment: Alignment, rotation: CGFloat) {
		switch direction {
		case .left:  return ("DELETE", Color("hdrRed"),   .trailing,  .topTrailing, .pi / 10)
		case .right: return ("KEEP",   Color("hdrGreen"), .leading,   .topLeading, -.pi / 10)
		case .up, .down: fatalError()
		}
	}

	var body: some View {
		let (text, color, edge, alignment, rotation) = stuff

		let isLoos = Fonts.fontChoice == .loos

		Color.clear
			.overlay(alignment: alignment) {
				Text(text)
					.kerning(5)
					.font(Fonts.overlay)
					.foregroundStyle(color)
					.padding(.top, isLoos ? -4 : 2)
					.padding(.bottom, 2)
					.padding(.leading, 8)
					.padding(.trailing, 3)
					.overlay(RoundedRectangle(cornerRadius: 4, style: .continuous)
						.stroke(color, lineWidth: 4))
					.rotationEffect(Angle(radians: rotation))
					.padding(.top, 60)
					.padding(edge, 44)
			}
	}

}

#Preview {
	VStack {
		CardOverlay(direction: .left)
		CardOverlay(direction: .right)
	}
}

class CardOverlayWrapperView: UIView {

	private let hostingController: UIHostingController<AnyView>

	init(direction: SwipeDirection) {
		hostingController = UIHostingController(rootView: AnyView(
			CardOverlay(direction: direction)
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
