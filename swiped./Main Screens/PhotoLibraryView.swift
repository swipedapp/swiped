//
//  PhotoLibraryView.swift
//  swiped.
//
//  Created by Adam Demasi on 14/6/2025.
//

import SwiftUI

class PhotoCardStack: ObservableObject {
	@Published var cards: [PhotoCard] = []
	@Published var mainPhotoIndex = 0
}

struct PhotoLibraryView: View {

	private let columns = [
		GridItem(.adaptive(minimum: 100, maximum: 200), spacing: 2)
	]

	@EnvironmentObject var stack: PhotoCardStack

	var animation: Namespace.ID

	@State private var position = ScrollPosition(edge: .top)

	@Environment(\.presentationMode) var presentationMode

	func card(_ card: PhotoCard) -> some View {
		Color(uiColor: .secondarySystemBackground)
			.aspectRatio(contentMode: .fill)
			.overlay {
				Image(uiImage: card.fullImage ?? card.thumbnail ?? UIImage())
					.resizable()
					.scaledToFill()
					.aspectRatio(contentMode: .fill)
					.clipped()
			}
				.clipped()
				.border(card.id == stack.mainPhotoIndex ? Color("brandGreen") : .clear, width: 2)
	}

	var body: some View {
		ScrollView {
			LazyVGrid(columns: columns, spacing: 2) {
				ForEach(stack.cards) { card in
					let view = self.card(card)
						.id(card.id)

					if card.id == stack.mainPhotoIndex {
						return AnyView(view
							.navigationTransition(.zoom(sourceID: "CardToLibraryView", in: animation)))
					} else {
						return AnyView(view)
					}
				}
			}
		}
			.scrollPosition($position)
			.animation(.default, value: position)
			.onAppear {
				if !stack.cards.isEmpty {
					position.scrollTo(id: stack.cards[stack.mainPhotoIndex].id,
														anchor: .center)
				}
			}
			.navigationTitle("Photos")
			.navigationBarTitleDisplayMode(.inline)
			.toolbar {
				ToolbarItem(placement: .primaryAction) {
					Button(role: .close) {
						presentationMode.wrappedValue.dismiss()
					}
				}
			}
			.backgroundStyle(.regularMaterial)
	}

}

#Preview {
	@Previewable @Namespace var animation

	let demoPhotos = ["2871", "2884", "2948", "2965", "3106", "3116", "3213", "3244", "3293", "3383"]
		.map { UIImage(named: "IMG_\($0).HEIC")! }

	let photos = Array(repeating: 0, count: 20 + 1 + 20)
		.enumerated()
		.map { i, _ in
			PhotoCard(id: i, thumbnail: demoPhotos[i % demoPhotos.count])
		}

	let stack = PhotoCardStack()
	stack.cards = photos
	stack.mainPhotoIndex = 21

	return NavigationView {
		PhotoLibraryView(animation: animation)
			.environmentObject(stack)
	}
}

