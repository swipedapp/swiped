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

	@State private var keepAnimation = false
	@State private var undoAnimation = false
	@State private var deleteAnimation = false
	@State private var shareAnimation = false

	func bottomButton<T>(image: Image, text: Text, action: Action, animate: Binding<Bool>, effect: T) -> some View where T : IndefiniteSymbolEffect, T : SymbolEffect {
		return Button(action: {
			animate.wrappedValue = true
			self.delegate?.didTapButton(action: action)

			DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
				animate.wrappedValue = false
			}
		}, label: {
			VStack(spacing: 2) {
				image
					.font(.custom("LoosExtended-Medium", size: 24))
					.frame(width: 30, height: 30, alignment: .center)
					.symbolEffect(effect, options: .speed(2), isActive: animate.wrappedValue)
				text
				.font(.custom("LoosExtended-Medium", size: 12))
				/*
					just testing sf expanded. it doesnt look too far off loos.
					.font(.caption)
					.fontWidth(.expanded)
				 */
			}
			.padding(4)
			.frame(width: 60, height: 50)
		})
		.buttonStyle(.glass)
		.glassEffectID(1, in: namespace)
	}

	var body: some View {
		GlassEffectContainer {
			HStack {

				bottomButton(image: Image(systemName: "xmark"),
										 text: Text("Delete"),
										 action: .delete,
										 animate: $deleteAnimation,
										 effect: .drawOff)

				bottomButton(image: Image(systemName: "arrow.uturn.backward"),
										 text: Text("Undo"),
										 action: .undo,
										 animate: $undoAnimation,
										 effect: .drawOff)

				bottomButton(image: Image(systemName: "square.and.arrow.up"),
										 text: Text("Share"),
										 action:.keep,
										 animate: $shareAnimation,
										 effect: .drawOff)

				bottomButton(image: Image(systemName: "checkmark"),
										 text: Text("Keep"),
										 action:.keep,
										 animate: $keepAnimation,
										 effect: .drawOff)
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
