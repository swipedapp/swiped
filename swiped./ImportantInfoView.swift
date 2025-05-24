//
//  ImportantInfoView.swift
//  swiped.
//
//  Created by tobykohlhagen on 24/5/2025.
//

import SwiftUI

struct ImportantInfoView: View {
	var body: some View {
			
					Section(content: {}, header: {
						ZStack(alignment: .top) {
							HStack {
								Image(systemName: "chevron.down")
								Text("Swipe down to dismiss")
								Image(systemName: "chevron.down")
							}
							.font(.custom("LoosExtended-Regular", size: 14))
						}
					})
		NavigationView {
			VStack {
	
				Image(systemName: "exclamationmark.shield.fill")
					.font(.system(size: 80))
					.foregroundColor(.primary)
					.padding([.bottom, .top], 20)
				Spacer()
				Text("You're on iOS 17.1")
				//.font(.custom("LoosExtended-Bold", size: 23))
					.font(.custom("LoosExtended-Bold", size: 23))
					.padding(.bottom, 20)
				Form {
					Section {
						Text("As we continue to pave the way for the future of this app, we sometimes need new tools. Tools that simply don't exist on your version of iOS.\n\nWe unfortunately will be dropping support for your version of iOS to adapt to the evolution of tomorrows tech. We know it's not ideal, but we recommend you update to a later version of iOS to get the latest updates from this app.")
							.listRowBackground(Color(.systemBackground))
							.font(.custom("LoosExtended-Regular", size: 16))
						
						
					}
					
				}
				.scrollContentBackground(.hidden)
				.background(Color(uiColor: .systemBackground))
				Spacer()
			}
		}
		.background(Color(uiColor: .systemBackground))
	}
}

#Preview {
    ImportantInfoView()
}
