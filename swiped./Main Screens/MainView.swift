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

	@EnvironmentObject var appState: AppState
	@EnvironmentObject var cardInfo: CardInfo

	@EnvironmentObject var sheetManager: SheetManager
	
	@State private var trigger = 0

	@State private var coordinator: MainViewControllerView.Coordinator?

	var body: some View {
		KeyframeAnimator(initialValue: 0.0, trigger: trigger) { value in
			VStack(spacing: 0) {
				ZStack {
					CardInfoView()
						.opacity(cardInfo.card == nil || appState.summary ? -value : value)

					CardInfoView(logo: true)
						.opacity(cardInfo.card == nil || appState.summary ? value : -value)
				}

				ZStack {
					BehindView(delegate: coordinator)
						.opacity(appState.summary ? value : -value)

					MainViewControllerView(onCoordinatorCreated: { coordinator in
						self.coordinator = coordinator
					})
						.background(.clear)
						.opacity(appState.summary ? -value : value)
						.padding(.bottom, 65)

					VStack {
						Spacer()

						ActionButtonsView(delegate: coordinator)
							.opacity(appState.summary ? -value : value)
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
			trigger += 1
		}
		.onChange(of: appState.summary) { oldValue, newValue in
			trigger += 1
		}
	}
	
}

#Preview("Main") {
	let appState = AppState(summary: false)
	let cardInfo = CardInfo()
	cardInfo.setCard(nil, position: 0)

	return MainView()
		.environmentObject(appState)
		.environmentObject(cardInfo)
		.environmentObject(SheetManager())
}

#Preview("Summary") {
	let appState = AppState(summary: true)
	let cardInfo = CardInfo()
	cardInfo.setCard(nil, position: 0)

	return MainView()
		.environmentObject(appState)
		.environmentObject(cardInfo)
		.environmentObject(SheetManager())
}

#Preview("Animating") {
	let appState = AppState(summary: false)
	let cardInfo = CardInfo()
	cardInfo.setCard(nil, position: ViewController.cardsPerStack)

	return MainView()
		.environmentObject(appState)
		.environmentObject(cardInfo)
		.environmentObject(SheetManager())
		.onAppear {
			Timer.scheduledTimer(withTimeInterval: 2, repeats: true) { _ in
				appState.setSummary(!appState.summary)
			}
		}
}
