//
//  InternalView.swift
//  swiped.
//
//  Created by tobykohlhagen on 12/5/2025.
//

import SwiftUI

struct InternalView: View {

	@State
	var sync: Bool = false
	var body: some View {
		Spacer()
		VStack {
			Text("Be careful what you wish for!").font(.custom("LoosExtended-Bold", size: 16))
			Text("Things in here are experimental, and could fail.").font(.custom("LoosExtended-Regular", size: 16))
		}

		Form {
			Section {
				NavigationLink("App Icons") {
					SettingsIconView()
				}
				Toggle(isOn: $sync) {
					Text("Disable Sync")
						.font(.custom("LoosExtended-Regular", size: 16))
				}
			}

			
		}
		}
		
	}

#Preview {
	InternalView()
}
