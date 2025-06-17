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

	private let photosController = PhotosController()

	@Environment(\.modelContext) var modelContext {
		didSet {
			photosController.db = DatabaseController(modelContainer: modelContext.container)
		}
	}

	@State var isScaling = false
	@State var scale: CGFloat = 1

	@State var libraryViewOpen = false
	@State var libraryViewReady = false
	@State var libraryViewStack = PhotoCardStack()

	@State var fullScreenOpen = false

	@Namespace private var animation

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
						.matchedTransitionSource(id: "CardToLibraryView", in: animation)

					if card.asset?.mediaType == .video {
						Image(systemName: "play.circle")
							.font(.system(size: 48))
							.foregroundStyle(.white)
							.shadow(color: .black.opacity(0.2),
											radius: 5,
											x: 0, y: 0)
							.accessibilityLabel("Play")
					}

					if card.fullImage == nil {
						ProgressView()
							.controlSize(.large)
							.tint(.white)
							.shadow(color: .black.opacity(0.2),
											radius: 5,
											x: 0, y: 0)
					}
				}
				.padding(.horizontal, 25)
				.padding(.vertical, 30)
				.scaleEffect(scale)
#if INTERNAL
				// INTERNAL FUNCTION: Library view - not ready yet
				.gesture(MagnifyGesture()
					.onChanged({ value in
						isScaling = true
						scale = value.magnification

						// Start loading early
						if scale < 0.9 && !libraryViewReady {
							Task {
								await getLibraryViewPhotos()
							}
						}
					})
					.onEnded({ value in
						if libraryViewReady {
							openLibraryView()
						} else if scale > 1.1 {
							fullScreenOpen = true
						}

						withAnimation(.bouncy(duration: 0.3)) {
							scale = 1
						} completion: {
							isScaling = false
						}
					}))
					.accessibilityZoomAction { action in
						switch action.direction {
						case .zoomOut:
							Task {
								await getLibraryViewPhotos()
								openLibraryView()
							}

						case .zoomIn:
							fullScreenOpen = true
						}
					}
					.onTapGesture {
						fullScreenOpen = true
					}
#endif
			}
		}
			.onChange(of: libraryViewReady) { oldValue, newValue in
				if newValue && scale == 1 {
					openLibraryView()
				}
			}
			.sheet(isPresented: $libraryViewOpen) {
				NavigationView {
					PhotoLibraryView(animation: animation)
						.environmentObject(libraryViewStack)
				}
					.presentationBackground(.clear)
					.navigationTransition(.zoom(sourceID: "CardToLibraryView", in: animation))
			}
			.fullScreenCover(isPresented: $fullScreenOpen) {
				FullScreenView()
					.environmentObject(card)
					.navigationTransition(.zoom(sourceID: "CardToLibraryView", in: animation))
			}
			.onChange(of: libraryViewOpen) { oldValue, newValue in
				if !newValue {
					libraryViewReady = false
					libraryViewStack.cards.removeAll()
				}
			}
	}

	private func getLibraryViewPhotos() async {
		guard let photos = try? await photosController.fetchPhotosAround(card: card) else {
			return
		}

		let stack = PhotoCardStack()
		stack.cards = photos
		stack.mainPhotoIndex = photos.count / 2
		libraryViewStack = stack

		libraryViewReady = true
	}

	private func openLibraryView() {
		withAnimation(.linear(duration: 1)) {
			libraryViewOpen = true
		}
	}

}

#Preview {
	let card = PhotoCard(id: 0, photo: nil, asset: nil, fullImage: UIImage(named: "IMG_2871.HEIC"))
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
