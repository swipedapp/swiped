//
//  SettingsView.swift
//  swiped.
//
//  Created by Adam Demasi on 10/05/2025.
//

import SwiftUI

struct SettingsView: View {

	var version: String {
		Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
	}

	var build: String {
		Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as! String
	}

	@State
	var sync: Bool = false

	@State
	var showResetAlert: Bool = false

	var body: some View {
		NavigationView {
			Form {
				Section(content: {}, header: {
					HStack {
						Spacer()
						VStack(alignment: .center) {
							Text("SWIPED")
								.foregroundColor(.white)
								.font(.custom("LoosExtended-Bold", size: 50))
							+
							Text(".")
								.foregroundColor(.accentColor)
								.font(.custom("LoosExtended-Bold", size: 50))

							Text("Version \(version) (\(build))")
								.font(.custom("LoosExtended-Bold", size: 18))
						}
						Spacer()
					}
						.padding(.vertical, 30)
				})

//				Section {
//					Toggle(isOn: $sync) {
//						Text("Sync")
//							.font(.custom("LoosExtended-Bold", size: 16))
//					}
//				}

				Section {
					NavigationLink("Icon") {
						SettingsIconView()
					}
				}

				Section {
					Button(action: {
						showResetAlert = true
					}, label: {
						HStack {
							Spacer()
							Label("Reset Database", systemImage: "xmark.bin")
								.font(.custom("LoosExtended-Bold", size: 16))
							Spacer()
						}
					})
						.foregroundColor(.red)
				}
			}
				.alert("You will lose all statistics you have collected so far.", isPresented: $showResetAlert, actions: {
					Button("Reset", role: .destructive) {
						DatabaseController.shared.reset()
					}
					Button("Cancel", role: .cancel) {}
				})
		}
	}

}

#Preview {
	SettingsView()
}
