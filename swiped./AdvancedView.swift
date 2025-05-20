
//
//  AdvancedView.swift
//  swiped.
//
//  Created by tobykohlhagen on 20/5/2025.
//
import SwiftUI
import Combine

struct AdvancedView: View {
	@AppStorage("sync")
	var sync: Bool = false
	var body: some View {
		Spacer()
		VStack {
			
			Form {
				Section {
					Toggle(isOn: $sync) {
						Text("Disable Sync")
							.font(.custom("LoosExtended-Regular", size: 16))
					}
					.listRowBackground(Color("listRowBackground"))
				}
				
				
			}
			.scrollContentBackground(.hidden)
			.background(Color(uiColor: .systemBackground))
		}
		
	}
}

#Preview {
	AdvancedView()
}

