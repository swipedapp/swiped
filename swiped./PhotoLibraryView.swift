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

	@State var currentIndex = 0

	@State private var position = ScrollPosition(edge: .leading)

	@State private var offsetX: CGFloat = 0

	@Environment(\.presentationMode) var presentationMode

	func card(_ card: PhotoCard, geometry: GeometryProxy) -> some View {
		Image(uiImage: card.fullImage ?? card.thumbnail ?? UIImage())
			.resizable()
			.scaledToFill()
			.frame(width: geometry.size.width - 40,
						 height: geometry.size.height - 20,
						 alignment: .center)
			.background(.secondary)
			.aspectRatio(contentMode: .fill)
			.clipped()
			.clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
			.overlay(RoundedRectangle(cornerRadius: 8, style: .continuous)
				.fill(.clear)
				.stroke(card.id == stack.mainPhotoIndex ? Color("brandGreen") : Color.clear))
			.padding(.horizontal, 5)
			.padding(.vertical, 10)
	}

	var body: some View {
		GeometryReader { geometry in
			ScrollView(.horizontal) {
				LazyHStack(spacing: 0) {
					ForEach(stack.cards) { photo in
						card(photo, geometry: geometry)
							.id(photo.id)
					}
				}
				.scrollTargetLayout()
				.padding(.horizontal, 15)
			}
			.scrollIndicators(.hidden)
			.scrollPosition($position)
			.scrollTargetBehavior(.viewAligned)
			.animation(.default, value: position)
			.onAppear {
				currentIndex = stack.mainPhotoIndex

				if !stack.cards.isEmpty {
					position.scrollTo(id: stack.cards[currentIndex].id)
				}
			}
			.onChange(of: currentIndex) { oldValue, newValue in
				if newValue < stack.cards.count {
					position.scrollTo(id: stack.cards[newValue].id)
				}
			}
			.onScrollGeometryChange(for: CGFloat.self) { geometry in
				geometry.contentOffset.x
			} action: { oldValue, newValue in
				if oldValue != newValue {
					offsetX = newValue
				}
			}
			.onChange(of: offsetX) {
				let cardWidth = geometry.size.width - 40
				let index = Int(round(offsetX / cardWidth))
				let clampedIndex = max(0, min(index, stack.cards.count - 1))
				if currentIndex != clampedIndex {
					currentIndex = clampedIndex
				}
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
	}

}

#Preview {
	let photos = Array(repeating: 0, count: 3).enumerated().map { i, _ in
		PhotoCard(id: i, thumbnail: UIImage(systemName: i % 2 == 0 ? "sparkles" : "star"))
	}

	let stack = PhotoCardStack()
	stack.cards = photos
	stack.mainPhotoIndex = 1

	return NavigationView {
		PhotoLibraryView()
			.environmentObject(stack)
	}
}

