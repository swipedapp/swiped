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
				
				Image(systemName: "exclamationmark.bubble")
					.font(.system(size: 80))
					.foregroundColor(.primary)
					.padding([.bottom, .top], 20)
				Spacer()
				Text("Known Issues")
					.font(Fonts.title)
					.padding(.bottom, 20)
				
				VStack(alignment: .leading) {
					
						Text("\(Image(systemName: "exclamationmark.bubble")) Known issue")
						Text("\(Image(systemName: "text.bubble.badge.clock")) Patching")
						Text("\(Image(systemName: "checkmark.bubble.fill")) Patched in next update")

					
					Spacer()
				}
				.font(Fonts.body)
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
