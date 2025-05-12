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
		
		Form {
			Section {
				NavigationLink("App Icons") {
					SettingsIconView()
				}
			}

			Toggle(isOn: $sync) {
				Text("Disable Sync")
					.font(.custom("LoosExtended-Regular", size: 16))
			}
		}
		}
		
	}

#Preview {
	InternalView()
}
