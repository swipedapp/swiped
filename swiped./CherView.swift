//
//  CherView.swift
//  swiped.
//
//  Created by tobykohlhagen on 7/6/2025.
//

/// NOTE FOR LURKERS: This is the ShareView. But it's called CherView because... Cher. It's complicated...

import SwiftUI

struct CherView: View {
	@State var showCher = false
	
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
		ZStack {
			// main content
			mainContent
			
			// top sliding sheet
			if showCher {
				VStack {
					sheetContent
						.background(Color(.systemBackground))
						.cornerRadius(16)
						.shadow(radius: 10)
						.padding()
					Spacer()
				}
				.background(
					Color.black.opacity(0.3)
						.ignoresSafeArea()
						.onTapGesture {
							showCher = false
						}
				)
				.offset(y: showCher ? 0 : -300)
				.opacity(showCher ? 1 : 0)
				.animation(.spring(), value: showCher)
			}
		}
	}
	
	var mainContent: some View {
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
				
				// button to show top sheet
				Button(action: {
					showCher = true
				}) {
					buttonLabel(image: Image(systemName: "ellipsis"),
											text: Text("More"))
				}
			}
		}
		.presentationDetents([.height(130)])
		.presentationDragIndicator(.visible)
	}
	
	var sheetContent: some View {
		VStack(spacing: 20) {
			HStack {
				Text("more options")
					.font(.custom("LoosExtended-Regular", size: 18))
					.fontWeight(.semibold)
				Spacer()
				Button(action: {
					showCher = false
				}) {
					Image(systemName: "xmark.circle.fill")
						.foregroundColor(.secondary)
						.font(.title2)
				}
			}
			
			// add whatever additional options u want here
			VStack(spacing: 15) {
				Button(action: {
					// ur custom action
					showCher = false
				}) {
					HStack {
						Image(systemName: "star")
						Text("custom option 1")
						Spacer()
					}
					.padding()
					.background(Color(.systemGray6))
					.cornerRadius(8)
				}
				
				Button(action: {
					// another custom action
					showCher = false
				}) {
					HStack {
						Image(systemName: "heart")
						Text("custom option 2")
						Spacer()
					}
					.padding()
					.background(Color(.systemGray6))
					.cornerRadius(8)
				}
			}
		}
		.padding()
		.frame(maxWidth: .infinity)
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
