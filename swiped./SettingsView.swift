//
//  SettingsView.swift
//  swiped.
//
//  Created by Adam Demasi on 10/05/2025.
//
import SwiftUI

struct SettingsView: View {
	@State var showRestriction = false
	let commitInfo = Bundle.main.infoDictionary?["GitCommitHash"] as? String ?? "Unknown"
	
	@AppStorage("timestamps")
	var timestamps: Bool = false
	
	var version: String {
		Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
	}

	var build: String {
		Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as! String
	}

	@AppStorage("sync")
	var sync: Bool = false
	

	@State
	var showResetAlert: Bool = false

	var body: some View {
		NavigationView {
			VStack {
				Form {
					Section(content: {}, header: {
						HStack {
							Spacer()
							VStack(alignment: .center) {
#if INTERNAL
								Text("INTERNAL")
									.foregroundColor(.primary)
									.font(.custom("LoosExtended-Bold", size: 40))
								+
								Text(".")
									.foregroundColor(Color("brandGreen"))
									.font(.custom("LoosExtended-Bold", size: 40))
#elseif DEBUG
								Text("CANDIDATE")
									.foregroundColor(.primary)
									.font(.custom("LoosExtended-Bold", size: 35))
								+
								Text(".")
									.foregroundColor(Color("brandGreen"))
									.font(.custom("LoosExtended-Bold", size: 35))
								Text("Build \(build)")
									.font(.custom("LoosExtended-Medium", size: 18))
#else
								Text("SWIPED")
									.foregroundColor(.primary)
									.font(.custom("LoosExtended-Bold", size: 50))
								+
								Text(".")
									.foregroundColor(Color("brandGreen"))
									.font(.custom("LoosExtended-Bold", size: 50))
								Text("Version \(version) (\(build))")
									.font(.custom("LoosExtended-Medium", size: 18))
#endif
							}
							Spacer()
						}
						.padding(.vertical, 30)
					})
					syncSection
					
#if INTERNAL
					// INTERNAL FLAGS
					
					
					Section {
						NavigationLink("Internal") {
							InternalView()
						}
						.font(.custom("LoosExtended-Regular", size: 16))
						.listRowBackground(Color("listRowBackground"))
					}
					
					
#endif
					// Production flags
					Toggle(isOn: $timestamps) {
						
						Text("Show relative timestamps")
							.font(.custom("LoosExtended-Regular", size: 16))
							
					}.listRowBackground(Color("listRowBackground"))
					NavigationLink("App Icons") {
						SettingsIconView()
					}.listRowBackground(Color("listRowBackground")).font(.custom("LoosExtended-Regular", size: 16))
					
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
						.listRowBackground(Color("listRowBackground"))
					}
				}
					.scrollContentBackground(.hidden)
					.background(Color(uiColor: .systemBackground))
					.alert("You will lose all statistics you have collected so far. Are you sure you want to do this?", isPresented: $showResetAlert, actions: {
						Button("Continue", role: .destructive) {
							DatabaseController.shared.reset()
						}
						Button("Cancel", role: .cancel) {}
					})
				
				Spacer()
				
				Text(commitInfo).opacity(0.5).font(.custom("LoosExtended-Medium", size: 16))
			}
				.background(Color(uiColor: .systemBackground))
		}
	}
	
	var syncSection: some View {
		Section {
			HStack {
				Text("SYNC.")
					.font(.custom("LoosExtended-Bold", size: 16))
					.foregroundColor(ServerController.shared.syncFailed ? .black : .primary)
				Spacer()
				if (!sync) {
					Text(ServerController.shared.syncFailed ? "Restricted." : "Connected")
						.font(.custom("LoosExtended-Regular", size: 16))
						.foregroundColor(ServerController.shared.syncFailed ? .black : Color("syncStatus"))
						.onTapGesture {
							if ServerController.shared.syncFailed {
								showRestriction = true
							}
						}
						.sheet(isPresented: $showRestriction) {
							RestrictionView()
						}
				} else {
					Text("Disabled")
						.font(.custom("LoosExtended-Regular", size: 16))
						.foregroundColor(.gray)
				}
				
				
			}
		}
		.listRowBackground(ServerController.shared.syncFailed ? .yellow : Color("listRowBackground"))
	}
}


#Preview {
	SettingsView()
}

