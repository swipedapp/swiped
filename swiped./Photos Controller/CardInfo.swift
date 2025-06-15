//
//  CardInfo.swift
//  swiped.
//
//  Created by Adam Demasi on 15/6/2025.
//

import SwiftUI

class CardInfo: ObservableObject {
	@Published var summary = false
	@Published var position = 0
	@Published var card: PhotoCard?

	init(summary: Bool = false) {
		self.summary = summary
	}

	func setCard(_ card: PhotoCard?, position: Int, summary: Bool) {
		withAnimation {
			self.card = card
			self.position = position
			self.summary = summary
		}
	}

	func setSummary(_ summary: Bool) {
		withAnimation {
			self.summary = summary
		}
	}
}
