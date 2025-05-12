//
//  SettingsView.swift
//  swiped.
//
//  Created by Adam Demasi on 10/05/2025.
//

import SwiftUI

struct SettingsView: View {
	let commitInfo = Bundle.main.infoDictionary?["GitCommitHash"] as? String ?? "Unknown"
	
	@AppStorage("timestamps")
	var timestamps: Bool = false
	
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
							#if INTERNAL
							Text("INTERNAL")
								.foregroundColor(.white)
								.font(.custom("LoosExtended-Bold", size: 40))
							+
							Text(".")
								.foregroundColor(.accentColor)
								.font(.custom("LoosExtended-Bold", size: 40))
							#elseif DEBUG
							Text("CANDIDATE")
								.foregroundColor(.white)
								.font(.custom("LoosExtended-Bold", size: 35))
							+
							Text(".")
								.foregroundColor(.accentColor)
								.font(.custom("LoosExtended-Bold", size: 35))
							Text("Build \(build)")
								.font(.custom("LoosExtended-Medium", size: 18))
							#else
							Text("SWIPED")
								.foregroundColor(.white)
								.font(.custom("LoosExtended-Bold", size: 50))
							+
							Text(".")
								.foregroundColor(.accentColor)
								.font(.custom("LoosExtended-Bold", size: 50))
							Text("Version \(version) (\(build))")
								.font(.custom("LoosExtended-Medium", size: 18))
							#endif
						}
						Spacer()
					}
						.padding(.vertical, 30)
				})
				#if RELEASE || DEBUG
				Section {
					HStack {
						Text("SYNC.")
							.font(.custom("LoosExtended-Bold", size: 16))
						Spacer()
						Text(ServerController.shared.syncFailed ? "Could not verify signature." : "Connected.")
							.font(.custom("LoosExtended-Regular", size: 16))
							.foregroundColor(ServerController.shared.syncFailed ? .yellow : .accentColor)
						
					}
				}
				
				#endif
				
				#if INTERNAL
				Section {
					HStack {
						Text("SYNC.")
							.font(.custom("LoosExtended-Bold", size: 16))
						Spacer()
						Text("Unavailable")
							.font(.custom("LoosExtended-Regular", size: 16))
							.foregroundColor(.gray)
						
					}
				}
				/*								Section {
				 Toggle(isOn: $sync) {
				 Text("Sync")
				 .font(.custom("LoosExtended-Bold", size: 16))
				 }
				 }*/
				// INTERNAL FLAGS
				
				
				Section {
					NavigationLink("Internal") {
						InternalView()
					}
				}
				
				
				#endif
				// Production flags
				Toggle(isOn: $timestamps) {
					Text("Show relative timestamps")
						.font(.custom("LoosExtended-Regular", size: 16))
				}


				Section {
					Button(action: {
						showResetAlert = true
					}, label: {
						HStack {
							Spacer()
							Label("Reset Database", systemImage: "xmark.bin")
								.font(.custom("LoosExtended-Medium", size: 16))
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
		Text(commitInfo).opacity(0.5).font(.custom("LoosExtended-Medium", size: 16))
	}
		.backgroundColor = .black
}

#Preview {
	SettingsView()
}

