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

	weak var delegate: Delegate?

	@EnvironmentObject var cardInfo: CardInfo

	func bottomButton(text: Text, action: Action) -> some View {
		return Button(action: {
			self.delegate?.didTapButton(action: action)
		}, label: {
			text
		})
			.frame(height: 68)
	}

	var body: some View {
		VStack(spacing: 0) {
			CardInfoView()

			ZStack {
				BehindView(delegate: delegate)
					.opacity(cardInfo.summary ? 1 : 0)
					.animation(.easeOut(duration: 0.5), value: cardInfo.summary)

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
						.opacity(cardInfo.summary ? 0 : 1)
						.animation(.easeOut(duration: 0.5), value: cardInfo.summary)
				}
			}
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
