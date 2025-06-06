//
//  KnownIssuesView.swift
//  swiped.
//
//  Created by tobykohlhagen on 6/6/2025.
//

import SwiftUI

struct KnownIssuesView: View {
	var body: some View {
		NavigationView {
			VStack {
				
				Image(systemName: "xmark.shield.fill")
					.font(.system(size: 80))
					.foregroundColor(.primary)
					.padding([.bottom, .top], 20)
				Spacer()
				Text("Known Issues")
				//.font(.custom("LoosExtended-Bold", size: 23))
					.font(.custom("LoosExtended-Bold", size: 23))
					.padding(.bottom, 20)
				
				VStack(alignment: .leading) {
						Text("Hello World")
					
					Spacer()
				}
				.font(.custom("LoosExtended-Regular", size: 16))
				.padding(.horizontal, 30)
				.padding(.vertical, 20)
			}
			.background(Color(uiColor: .systemBackground))
			.navigationBarHidden(true)
		}
	}
}


#Preview {
    KnownIssuesView()
}
