//
//  RestrictionView.swift
//  swiped.
//
//  Created by tobykohlhagen on 13/5/2025.
//

import SwiftUI

struct RestrictionView: View {
	var body: some View {
		NavigationView {
			VStack {
				Image(systemName: "lock.fill")
					.font(.system(size: 80))
					.foregroundColor(.yellow)
					.padding([.bottom, .top], 20)
				Spacer()
				Text("About Restriction")
					//.font(.custom("LoosExtended-Bold", size: 23))
					.font(.custom("LoosExtended-Bold", size: 23))
					.padding(.bottom, 20)
				Form {
					Section {
						Text("To ensure the safety of our users, our app generates a cryptographically unique token that ensures your copy of 'swiped.' has not been tampered and/or distributed by a third party.\n\nYour device could either not connect to 'SYNC.', or could not verify the authenticity of the application with 'SYNC.'\n\nWhile in this state, your device is unable to use syncing services.").listRowBackground(Color(.systemBackground))
						
						
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
	RestrictionView()
}
