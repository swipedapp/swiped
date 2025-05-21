//
//  BehindView.swift
//  swiped.
//
//  Created by tobykohlhagen on 2/5/2025.
//

import SwiftUI
import SQLite

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
						return Circle()
							.fill(Color((i * 10) + j < keptCount ? UIColor.sampleGreen : UIColor.sampleRed))
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

	weak var delegate: Delegate?

	var body: some SwiftUI.View {
		let db = DatabaseController.shared

		return VStack(alignment: .leading, spacing: 10) {
			SummaryGridView(totalKept: db.getTotalKept(), totalDeleted: db.getTotalDeleted())

			VStack(alignment: .leading, spacing: 10) {
				Text("\(db.getTotalKept().formatted()) kept")
				Text("\(db.getTotalDeleted().formatted()) deleted")
				Text("\(Self.fileSizeFormatter.string(fromByteCount: Int64(db.getSpaceSaved()))) saved")
				Text("SwipeScore: \(db.calcSwipeScore().formatted())")
			}
				.font(.custom("LoosExtended-Bold", size: 18))
				.multilineTextAlignment(.center)
				.padding(.vertical, 20)

			Button {
				delegate?.didTapContinue()
			} label: {
				Text("Continue")
			}
				.font(.custom("LoosExtended-Bold", size: 16))
				.padding(.vertical, 10)
				.background(Color("brandGreen").cornerRadius(8))
				.frame(maxWidth: .infinity)
				.foregroundColor(.black)
		}
			.padding(20)
	}
}

#Preview {
	BehindView()
}
