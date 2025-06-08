//
//  CherView.swift
//  swiped.
//
//  Created by tobykohlhagen on 7/6/2025.
//

/// NOTE FOR LURKERS: This is the ShareView. But it's called CherView because... Cher. It's complicated...

import SwiftUI
import UniformTypeIdentifiers

struct CherView: View {
	let onDismiss: () -> Void
	@EnvironmentObject var cardInfo: CardInfo
	
	private let photosController = PhotosController()
	
	@Environment(\.modelContext) var modelContext {
		didSet {
			photosController.db = DatabaseController(modelContainer: modelContext.container)
		}
	}

	@State var showMessages = false

	@State var shareData: Data?

	func buttonLabel(image: Image, text: Text) -> some View {
		VStack(alignment: .center) {
			image
				.resizable()
				.aspectRatio(contentMode: .fit)
				.font(.custom("LoosExtended-Regular", size: 28))
				.frame(width: 40, height: 40, alignment: .center)
			text
				.font(.custom("LoosExtended-Regular", size: 16))
				.lineLimit(1)
		}
		.frame(width: 110, alignment: .center)
		.foregroundColor(.primary)
	}
	
	var body: some View {
		VStack {
			ScrollView(.horizontal, showsIndicators: false) {
				HStack {
					ForEach(CherController.sources) { source in
						if source.isAvailable() {
							Button(action: {
								if source.id == "Messages" {
									if cardInfo.card?.asset?.mediaType == .image {
										shareData = (cardInfo.card?.thumbnail ?? cardInfo.card?.fullImage)?.jpegData(compressionQuality: 0.98)
									} else {
										// todo
									}

									showMessages = true
								} else {
									source.share(cardInfo, photosController)
									onDismiss()  // changed this
								}
							}, label: {
								buttonLabel(image: source.image,
														text: Text(source.name))
							})
						}
					}
					
					CherController.shareLink(cardInfo: cardInfo,
																	 photosController: photosController) {
						buttonLabel(image: Image("other"),
												text: Text("Other"))
					}
																	 .onTapGesture {
																		 onDismiss()  // changed this
																	 }
				}
			}
			Spacer()
		}
		.background(Color(.systemBackground))
		.presentationDetents([.height(130)])
		.presentationDragIndicator(.visible)
		.sheet(isPresented: $showMessages) {
			MessageComposeView(
				attachments: [
					MessageComposeView.MessageAttachment(data: shareData ?? Data(),
																							 typeIdentifier: UTType.jpeg.identifier,
																							 filename: "image.jpg")
				],
				isPresented: $showMessages
			)
				.ignoresSafeArea()
				.onChange(of: showMessages, { oldValue, newValue in
					if !newValue {
						onDismiss()
					}
				})
		}
	}
}


#Preview {
	let cardInfo = CardInfo()
	cardInfo.card = PhotoCard()
	
	return Color.white
		.sheet(isPresented: Binding(get: { true }, set: { _ in })) {
			CherView(onDismiss: {})
				.environmentObject(cardInfo)
		}
}
