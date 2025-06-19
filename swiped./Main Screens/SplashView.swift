//
//  SplashView.swift
//  swiped.
//
//  Created by Adam Demasi on 18/6/2025.
//

import SwiftUI

struct SplashView: View {
	public static let animationDuration: CGFloat = 2.5

	@State private var running = false
	@State private var waiting = false

	@EnvironmentObject private var cardInfo: CardInfo

	var body: some View {
		Color.black
			.overlay {
				KeyframeAnimator(initialValue: 0.0, repeating: true) { value in
					Color.black.overlay {
						Image("logo_solid")
							.resizable()
							.frame(width: 224, height: 224, alignment: .center)
							.offset(x: 0, y: -70.0 * value)
							.scaleEffect(1.0 - (value * 0.2))

						Text("SWIPED\(Text(".").foregroundColor(Color("brandGreen")))")
							.foregroundColor(.white)
							.font(.custom("LoosExtended-Bold", size: 50))
							.opacity(value)
							.offset(x: 0, y: 50.0 * value)
							.scaleEffect(value * 0.9)
							.blur(radius: 100.0 - (value * 100.0))
					}
				} keyframes: { _ in
					KeyframeTrack(\.self) {
						SpringKeyframe(0.0, duration: 1.0, spring: .snappy, startVelocity: 0)
						SpringKeyframe(1.0, duration: 1.0, spring: .snappy, startVelocity: 10)
						SpringKeyframe(1.0, duration: .infinity, spring: .snappy, startVelocity: 0)
					}
				}
					.ignoresSafeArea(.all, edges: .all)
			}
			.drawingGroup()
			.overlay {
				if waiting {
					ProgressView()
						.tint(.white)
						.offset(x: 0, y: 100)
				}
			}
			.ignoresSafeArea(.all, edges: .all)
			.onAppear {
				running = true

				Timer.scheduledTimer(withTimeInterval: Self.animationDuration, repeats: false) { _ in
					withAnimation(.linear(duration: 0.3)) {
						waiting = true
					}
				}
			}
			.onChange(of: cardInfo.appReady, { oldValue, newValue in
				if newValue {
					running = false
				}
			})
			.opacity(running ? 1 : 0)
	}
}

#Preview {
	SplashView()
}


