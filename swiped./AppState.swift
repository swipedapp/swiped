//
//  AppState.swift
//  swiped.
//
//  Created by Adam Demasi on 20/6/2025.
//

import SwiftUI

class AppState: ObservableObject {
	@Published var summary = false
	@Published var appReady = false

	init(summary: Bool = false) {
		self.summary = summary
	}

	func setSummary(_ summary: Bool) {
		withAnimation {
			self.summary = summary
		}
	}
}
