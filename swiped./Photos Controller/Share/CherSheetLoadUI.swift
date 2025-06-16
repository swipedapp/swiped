//
//  SwiftUIView.swift
//  swiped.
//
//  Created by tobykohlhagen on 22/5/2025.
//

import SwiftUI

struct CherSheetLoadUI: View {
	var body: some View {
		VStack {
			Spacer()

			Text("Preparing...")
				.font(Fonts.title)
			ProgressView()
				.controlSize(.large)

			Spacer()
		}
		
		.scrollContentBackground(.hidden)
		.interactiveDismissDisabled()
		.presentationDetents([.height(140)])
		.presentationDragIndicator(.hidden)
	}

}

#Preview {
	CherSheetLoadUI()
}
