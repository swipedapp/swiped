//
//  SwiftUIView.swift
//  swiped.
//
//  Created by tobykohlhagen on 22/5/2025.
//

import SwiftUI

struct CherSheetLoadUI: View {
	var body: some View {
		NavigationView {
			VStack {
				
				Text("Preparing..")
					.font(.custom("LoosExtended-Bold", size: 23))
				ProgressView()
					.controlSize(.large)
			}
			
			.scrollContentBackground(.hidden)
			.background(Color(uiColor: .systemBackground))
			Spacer()
		}
		.interactiveDismissDisabled()
		.presentationDetents([.height(130)])
		.presentationDragIndicator(.hidden)
	}

}

#Preview {
	CherSheetLoadUI()
}
