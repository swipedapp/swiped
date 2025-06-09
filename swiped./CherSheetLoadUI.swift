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
			HStack {
				
				Text("Preparing..")
					.font(.custom("LoosExtended-Medium", size: 20))
				
				ProgressView()
					//.controlSize(.large)
					
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
