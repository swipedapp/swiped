//
//  InternalView.swift
//  swiped.
//
//  Created by tobykohlhagen on 12/5/2025.
//

import SwiftUI

struct InternalView: View {
	@AppStorage("timestamps")
	var timestamps: Bool = false
	@State
	var sync: Bool = false
	var body: some View {
		
		Form {
			Section {
				NavigationLink("App Icons") {
					SettingsIconView()
				}
			}
			Toggle(isOn: $timestamps) {
				Text("Show relative timestamps")
					.font(.custom("LoosExtended-Regular", size: 16))
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
