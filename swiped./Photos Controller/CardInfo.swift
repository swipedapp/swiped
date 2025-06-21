//
//  CardInfo.swift
//  swiped.
//
//  Created by Adam Demasi on 15/6/2025.
//

import SwiftUI

class CardInfo: ObservableObject {
	@Published var position = 0
	@Published var card: PhotoCard?

	func setCard(_ card: PhotoCard?, position: Int) {
		withAnimation {
			self.card = card
			self.position = position
		}
	}
}
