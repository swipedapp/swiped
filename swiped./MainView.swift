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

	@State private var trigger = 0

	func bottomButton(text: Text, action: Action) -> some View {
		return Button(action: {
			self.delegate?.didTapButton(action: action)
		}, label: {
			text
		})
			.frame(height: 68)
	}

	var body: some View {
		KeyframeAnimator(initialValue: 0, trigger: trigger) { value in
			VStack(spacing: 0) {
				CardInfoView()

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

							bottomButton(text: Text("Keep"), action: .keep)
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
				LinearKeyframe(0, duration: 0.3)
				LinearKeyframe(0, duration: 0)
				LinearKeyframe(1, duration: 0.3)
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
	cardInfo.setCard(nil, summary: false)

	return MainView()
		.environmentObject(cardInfo)
		.onAppear {
			Timer.scheduledTimer(withTimeInterval: 2, repeats: true) { _ in
				cardInfo.setCard(nil, summary: !cardInfo.summary)
			}
		}
}

#Preview {
	let cardInfo = CardInfo()
	cardInfo.setCard(nil, summary: false)

	return MainView()
		.environmentObject(cardInfo)
}

#Preview {
	let cardInfo = CardInfo()
	cardInfo.setCard(nil, summary: true)

	return MainView()
		.environmentObject(cardInfo)
}
