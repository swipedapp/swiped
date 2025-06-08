//
//  CherView.swift
//  swiped.
//
//  Created by tobykohlhagen on 7/6/2025.
//

/// NOTE FOR LURKERS: This is the ShareView. But it's called CherView because... Cher. It's complicated...

import SwiftUI

struct CherView: View {
	@Environment(\.presentationMode) var presentationMode
	@EnvironmentObject var cardInfo: CardInfo
	
	private let photosController = PhotosController()
	
	@Environment(\.modelContext) var modelContext {
		didSet {
			photosController.db = DatabaseController(modelContainer: modelContext.container)
		}
	}
	
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
								source.share(cardInfo, photosController)
								presentationMode.wrappedValue.dismiss()
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
			Spacer()
		}
		.background(Color(.systemBackground))
		.transition(.move(edge: .top).combined(with: .opacity))
	}
}

#Preview {
	let cardInfo = CardInfo()
	cardInfo.card = PhotoCard()
	
	return Color.white
		.sheet(isPresented: Binding(get: { true }, set: { _ in })) {
			CherView()
				.environmentObject(cardInfo)
		}
}
