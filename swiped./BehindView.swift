//
//  BehindView.swift
//  swiped.
//
//  Created by tobykohlhagen on 2/5/2025.
//

import SwiftUI
import SwiftData

struct SummaryGridView: SwiftUI.View {
	
	let totalKept: Int
	let totalDeleted: Int
	
	var body: some SwiftUI.View {
		let total = totalKept + totalDeleted
		let keptCount = total == 0 ? 0 : Int((Double(totalKept) / Double(total) * 100).rounded(.toNearestOrAwayFromZero))
		
		return VStack {
			ForEach(0..<10) { i in
				HStack {
					ForEach(0..<10) { j in
						
						Circle()
							.fill(Color((i * 10) + j < keptCount ? "brandGreen" : "brandRed"))
					}
				}
			}
		}
	}
	
}

struct BehindView: SwiftUI.View {
	
	protocol Delegate: AnyObject {
		func didTapContinue()
	}
	
	private static let fileSizeFormatter = ByteCountFormatter()
	
	@EnvironmentObject var cardInfo: CardInfo
	
	@Environment(\.modelContext) var modelContext
	
	@State var totalKept = 0
	@State var totalDeleted = 0
	@State var spaceSaved: Int64 = 0
	@State var swipeScore: Int64 = 0

	weak var delegate: Delegate?
	
	var body: some SwiftUI.View {
		return VStack(alignment: .center, spacing: 10) {
			SummaryGridView(totalKept: totalKept,
											totalDeleted: totalDeleted)

			VStack(alignment: .leading, spacing: 10) {

				Text("\(totalKept.formatted()) kept")
					.frame(maxWidth: .infinity, alignment: .leading)
				Text("\(totalDeleted.formatted()) deleted")
					.frame(maxWidth: .infinity, alignment: .leading)
				Text("\(Self.fileSizeFormatter.string(fromByteCount: spaceSaved)) saved")
					.frame(maxWidth: .infinity, alignment: .leading)
				HStack {
					if #available(iOS 17.4, *) {
						// Use the correct symbol for this. Just saving my ass from a blank symbol :sob:
						Image(systemName: "medal.star.fill")
					} else {
						Image(systemName: "trophy.fill")
					}

					Text("\(swipeScore.formatted()) SwipeScore").font(.custom("LoosExtended-Medium", size: 18))
						.frame(maxWidth: .infinity, alignment: .leading)
				}


			}
			.font(.custom("LoosExtended-Bold", size: 18))
			.multilineTextAlignment(.leading)
			.padding(.vertical, 20)

			Button {
				delegate?.didTapContinue()
			} label: {
				Text("Continue")
					.frame(maxWidth: .infinity)
					.frame(height: 44)
			}
			.font(.custom("LoosExtended-Bold", size: 16))
			.buttonStyle(.glass)
			.background(Capsule().fill(Color("continueButton")))
		}
			.frame(maxWidth: 450)
			.padding(.horizontal, 20)
			.padding(.vertical, 40)
			.onChange(of: cardInfo.summary, { oldValue, newValue in
				if cardInfo.summary {
					Task {
						let db = DatabaseController(modelContainer: modelContext.container)
						self.totalKept = await db.getTotalKept()
						self.totalDeleted = await db.getTotalDeleted()
						self.spaceSaved = Int64(await db.getSpaceSaved())
						self.swipeScore = await db.calcSwipeScore()
					}
				}
			})
	}
}

#Preview {
	let info = CardInfo()
	info.setCard(nil, position: 0, summary: true)
	
	return BehindView()
		.environmentObject(info)
}
