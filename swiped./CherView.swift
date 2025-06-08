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

	@EnvironmentObject var cardInfo: CardInfo
	
	private let photosController = PhotosController()
	
	@Environment(\.modelContext) var modelContext {
		didSet {
			photosController.db = DatabaseController(modelContainer: modelContext.container)
		}
	}

	@Environment(\.presentationMode) var presentationMode

	@State var showMessages = false

	@State var shareItem: PhotosController.ShareItem?

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
					if MessageComposeView.isAvailable {
						Button(action: {
							Task {
								shareItem = try? await CherController.getData(cardInfo: cardInfo, photosController: photosController)
							}
						}, label: {
							buttonLabel(image: Image("messages"),
													text: Text("Messages"))
						})
					}

					ForEach(CherController.sources) { source in
						if source.isAvailable() {
							Button(action: {
								Task {
									await source.share(cardInfo, photosController)
									presentationMode.wrappedValue.dismiss()
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
																		 presentationMode.wrappedValue.dismiss()
																	 }
				}
			}
		}
		.background(Color(.systemBackground))
		.presentationDetents([.height(130)])
		.presentationDragIndicator(.visible)
		.sheet(item: $shareItem) { shareItem in
			messageComposeView(shareItem: shareItem)
		}
	}

	func messageComposeView(shareItem: PhotosController.ShareItem) -> some View {
		return AnyView(MessageComposeView(
			attachments: [
				MessageComposeView.MessageAttachment(data: shareItem.data,
																						 typeIdentifier: shareItem.type.identifier,
																						 filename: "image.\(shareItem.type.preferredFilenameExtension ?? "jpg")")
			],
			isPresented: $showMessages
		)
			.ignoresSafeArea()
			.onChange(of: showMessages, { oldValue, newValue in
				if !newValue {
					presentationMode.wrappedValue.dismiss()
					self.shareItem = nil
				}
			}))
	}
}


#Preview {
	@Previewable @State var show = true

	let cardInfo = CardInfo()
	cardInfo.card = PhotoCard()

	return Color.white
		.onTapGesture(perform: {
			show = true
		})
		.sheet(isPresented: $show) {
			CherView()
				.environmentObject(cardInfo)
		}
}
