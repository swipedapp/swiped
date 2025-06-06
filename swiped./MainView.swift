//
//  MainView.swift
//  swiped.
//
//  Created by Adam Demasi on 24/5/2025.
//

import SwiftUI

struct MainView: View {
	
	enum Action: Int {
		case undo = 1
		case delete = 2
		case keep = 3
	}
	
	protocol Delegate: AnyObject, BehindView.Delegate {
		func didTapButton(action: Action)
	}
	
	private enum AnimationPhase: CaseIterable {
		case start, middle, end
	}
	
	weak var delegate: Delegate?
	
	@EnvironmentObject var cardInfo: CardInfo
	
	@EnvironmentObject var sheetManager: SheetManager
	
	@State private var trigger = 0
	
	func bottomButton(text: Text, action: Action) -> some View {
		return Button(action: {
			if let data = cardInfo.card?.fullImage!.pngData() {
				let temp = FileManager.default.temporaryDirectory.appendingPathComponent("Photo.png")
				try! data.write(to: temp)
				//self.delegate?.didTapButton(action: action)
				CreativeKit.shareToPreview(
					clientID: Identifiers.CLIENT_ID,
					mediaType: .image,
					mediaData: data
				)
			}
			
		}, label: {
			text
		})
		.frame(height: 68)
	}
	
	var body: some View {
		KeyframeAnimator(initialValue: 0.0, trigger: trigger) { value in
			VStack(spacing: 0) {
				ZStack {
					CardInfoView()
						.opacity(cardInfo.card == nil || cardInfo.summary ? -value : value)

					CardInfoView(logo: true)
						.opacity(cardInfo.card == nil || cardInfo.summary ? value : -value)
				}

				ZStack {
					BehindView(delegate: delegate)
						.opacity(cardInfo.summary ? value : -value)

					Spacer()
					
					VStack(spacing: 0) {
						Spacer()
						
						HStack {
							bottomButton(text: Text("Delete"), action: .delete)
								.padding(.leading, 35)
							
							Spacer()
							
							bottomButton(text: Text("Undo"), action: .undo)
								.padding(.horizontal, 10)
							
							Spacer()
							
							bottomButton(text: Text("shar"), action:.keep)
							
								.padding(.trailing, 35)
						}
						.foregroundColor(.primary)
						.font(.custom("LoosExtended-Medium", size: 18))
						.opacity(cardInfo.summary ? -value : value)
					}
				}
			}
		} keyframes: { _ in
			KeyframeTrack(\.self) {
				LinearKeyframe(0.0, duration: 0.3)
				LinearKeyframe(0.0, duration: 0.0)
				LinearKeyframe(1.0, duration: 0.3)
			}
		}
		.onAppear {
			self.trigger += 1
		}
		.onChange(of: cardInfo.summary) { oldValue, newValue in
			self.trigger += 1
		}
	}
	
}

#Preview {
	let cardInfo = CardInfo()
	cardInfo.setCard(nil, position: ViewController.cardsPerStack, summary: false)

	return MainView()
		.environmentObject(cardInfo)
		.environmentObject(SheetManager())
		.onAppear {
			Timer.scheduledTimer(withTimeInterval: 2, repeats: true) { _ in
				cardInfo.setCard(nil, position: ViewController.cardsPerStack, summary: !cardInfo.summary)
			}
		}
}

#Preview {
	let cardInfo = CardInfo()
	cardInfo.setCard(nil, position: 0, summary: false)

	return MainView()
		.environmentObject(cardInfo)
		.environmentObject(SheetManager())
}

#Preview {
	let cardInfo = CardInfo()
	cardInfo.setCard(nil, position: 0, summary: true)

	return MainView()
		.environmentObject(cardInfo)
		.environmentObject(SheetManager())
}
