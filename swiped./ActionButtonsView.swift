//
//  ActionButtonsView.swift
//  swiped.
//
//  Created by Adam Demasi on 10/6/2025.
//

import SwiftUI

struct ActionButtonsView: View {

	private static let dateFormatter: DateFormatter = {
		let dateFormatter = DateFormatter()
		dateFormatter.dateStyle = .medium
		return dateFormatter
	}()

	private let photosController = PhotosController()

	enum Action: Int {
		case undo
		case delete
		case keep
		case share
	}

	protocol Delegate: AnyObject {
		func didTapButton(action: Action)
	}

	weak var delegate: Delegate?

	@EnvironmentObject var cardInfo: CardInfo

	@Environment(\.modelContext) var modelContext {
		didSet {
			photosController.db = DatabaseController(modelContainer: modelContext.container)
		}
	}

	@Namespace private var namespace

	@State var showCher = false

	@State private var keepAnimation = false
	@State private var undoAnimation = false
	@State private var deleteAnimation = false
	@State private var shareAnimation = false

	func bottomButton<T>(image: Image, text: Text, action: Action, animate: Binding<Bool>, effect: T) -> some View where T : IndefiniteSymbolEffect, T : SymbolEffect {
		return Button(action: {
			animate.wrappedValue = true

			if action == .share {
				showCher = true
			} else {
				self.delegate?.didTapButton(action: action)
			}

			DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
				animate.wrappedValue = false
			}
		}, label: {
			VStack(spacing: 2) {
				image
					.font(.system(size: 24))
					.frame(width: 30, height: 30, alignment: .center)
					.symbolEffect(effect, options: .speed(2), isActive: animate.wrappedValue)
				text
					.font(Fonts.extraSmall)
			}
			.padding(4)
			.frame(width: 60, height: 50)
		})
		.buttonStyle(.glass)
		.glassEffectID(1, in: namespace)
	}

	var shareButton: some View {
		if let asset = cardInfo.card?.asset,
			 asset.mediaType == .image || asset.mediaType == .video {
			let button = bottomButton(image: Image(systemName: "square.and.arrow.up"),
																text: Text("Share"),
																action:.share,
																animate: $shareAnimation,
																effect: .drawOff)

			if CherController.hasAnySources {
				return AnyView(button)
			} else {
				return AnyView(CherController.shareLink(cardInfo: cardInfo,
																								photosController: photosController,
																								body: {
					button
				}))
			}
		} else {
			return AnyView(EmptyView())
		}
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
										 action:.share,
										 animate: $shareAnimation,
										 effect: .drawOff)

				bottomButton(image: Image(systemName: "checkmark"),
										 text: Text("Keep"),
										 action:.keep,
										 animate: $keepAnimation,
										 effect: .drawOff)
			}
		}
			.opacity(cardInfo.summary ? 0 : 1)
			.transition(.opacity.animation(.linear(duration: 0.3)))
			.glassEffectUnion(id: 1, namespace: namespace)
			.sheet(isPresented: $showCher) {
				CherView()
					.environmentObject(cardInfo)
			}
	}

}

#Preview {
	let cardInfo = CardInfo()
	cardInfo.setCard(nil, position: 0, summary: false)

	return ActionButtonsView()
		.environmentObject(cardInfo)
		.environmentObject(SheetManager())
}
