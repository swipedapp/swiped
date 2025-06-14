//
//  SwiftUIView.swift
//  swiped.
//
//  Created by tobykohlhagen on 22/5/2025.
//

import SwiftUI

struct MigrationUI: View {
	var body: some View {
		NavigationView {
			VStack {
				
				Text("Updating..")
					.font(Fonts.title)
				Text("Moving Database to SwiftData")
					.font(Fonts.bodyMedium)
				ProgressView()
					.controlSize(.large)
			}
			
			.scrollContentBackground(.hidden)
			.background(Color(uiColor: .systemBackground))
			Spacer()
		}
		.interactiveDismissDisabled()
	}
	//.background(Color(uiColor: .systemBackground))
}

#Preview {
	MigrationUI()
}
