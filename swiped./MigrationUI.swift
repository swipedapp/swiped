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
				
				Text("Completing Update")
				//.font(.custom("LoosExtended-Bold", size: 23))
					.font(.custom("LoosExtended-Bold", size: 23))
				Text("Please wait..")
				//.font(.custom("LoosExtended-Bold", size: 23))
					.font(.custom("LoosExtended-Medium", size: 16))
				ProgressView()
				}

				.scrollContentBackground(.hidden)
				.background(Color(uiColor: .systemBackground))
				Spacer()
			}
		}
		//.background(Color(uiColor: .systemBackground))
	}

#Preview {
    MigrationUI()
}
