//
//  MainView.swift
//  swiped.
//
//  Created by Adam Demasi on 24/5/2025.
//

import SwiftUI

struct MainView: View {
	
	private enum AnimationPhase: CaseIterable {
		case start, middle, end
	}
	
	weak var delegate: BehindView.Delegate?

	@EnvironmentObject var cardInfo: CardInfo
	
	@EnvironmentObject var sheetManager: SheetManager
	
	@State private var trigger = 0
	
	var body: some View {
		KeyframeAnimator(initialValue: 0.0, trigger: trigger) { value in
			VStack(spacing: 0) {
				ZStack {
					CardInfoView()
						.opacity(cardInfo.card == nil || cardInfo.summary ? -value : value)

					CardInfoView(logo: true)
						.opacity(cardInfo.card == nil || cardInfo.summary ? value : -value)
				}

				BehindView(delegate: delegate)
					.opacity(cardInfo.summary ? value : -value)

				Spacer()

//				ZStack {
//
//					HStack {
//						Spacer()
//
//						VStack(spacing: 0) {
//							Spacer()
//						}
//						.foregroundColor(.primary)
//						.opacity(cardInfo.summary ? -value : value)
//						.padding(.trailing, 10)
//					}
//				}
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
