//
//  ActionButtonsView.swift
//  swiped.
//
//  Created by Adam Demasi on 10/6/2025.
//

import SwiftUI

struct ActionButtonsView: View {

	enum Action: Int {
		case undo = 1
		case delete = 2
		case keep = 3
	}

	protocol Delegate: AnyObject {
		func didTapButton(action: Action)
	}

	weak var delegate: Delegate?

	@EnvironmentObject var cardInfo: CardInfo

	@Namespace private var namespace

	func bottomButton(image: Image, text: Text, action: Action) -> some View {
		return Button(action: {
			self.delegate?.didTapButton(action: action)
		}, label: {
			VStack(spacing: 2) {
				image
					.font(.custom("LoosExtended-Medium", size: 24))
				text
					.font(.custom("LoosExtended-Medium", size: 12))
			}
			.padding(4)
			.frame(width: 60, height: 60)
		})
		.buttonStyle(.glass)
		.glassEffectID(1, in: namespace)
	}

	var body: some View {
		GlassEffectContainer {
			VStack {
				bottomButton(image: Image(systemName: "arrowshape.turn.up.right"), text: Text("Keep"), action:.keep)

				bottomButton(image: Image(systemName: "arrowshape.turn.up.left"), text: Text("Delete"), action: .delete)

				bottomButton(image: Image(systemName: "clock"), text: Text("Undo"), action: .undo)

				bottomButton(image: Image(systemName: "square.and.arrow.up"), text: Text("Share"), action:.keep)
			}
		}
		.glassEffectUnion(id: 1, namespace: namespace)
	}

}

#Preview {
	let cardInfo = CardInfo()
	cardInfo.setCard(nil, position: 0, summary: false)

	return ActionButtonsView()
		.environmentObject(cardInfo)
		.environmentObject(SheetManager())
}
