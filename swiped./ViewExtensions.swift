//
//  UIViewExtensions.swift
//  swiped.
//
//  Created by tobykohlhagen on 2/5/2025.
//

import SwiftUI

extension View {
	@ViewBuilder
	func overlayShadow() -> some View {
		self
			.shadow(color: .black, radius: 1, x: 0, y: 0)
			.shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 1)
	}
}
