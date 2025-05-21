//
//  BehindView.swift
//  swiped.
//
//  Created by tobykohlhagen on 2/5/2025.
//

import SwiftUI
import SQLite

struct BehindView: SwiftUI.View {

	protocol Delegate: AnyObject {
		func didTapContinue()
	}

	private static let fileSizeFormatter = ByteCountFormatter()

	weak var delegate: Delegate?

	var body: some SwiftUI.View {
		let db = DatabaseController.shared

		return VStack {
			Text("\(db.getTotalKept().formatted()) kept")
			Text("\(db.getTotalDeleted().formatted()) deleted")
			Text("\(Self.fileSizeFormatter.string(fromByteCount: Int64(db.getSpaceSaved()))) saved")
			Text("SwipeScore: \(db.calcSwipeScore().formatted())")

			Button {
				delegate?.didTapContinue()
			} label: {
				Text("Continue")
			}
				.foregroundColor(Color("brandGreen"))
		}
			.font(.custom("LoosExtended-Bold", size: 16))
			.multilineTextAlignment(.center)
	}
}

#Preview {
	BehindView()
}
